import 'package:fixmytown_citizen/app/widgets/status_chip.dart';
import 'package:fixmytown_citizen/app/widgets/workflow_timeline.dart';

/// The v1 pipeline — deliberately has no AI-validation step. AI features are
/// deferred (see docs/10-ai-design.md and docs/11-roadmap.md): every report
/// goes straight to human review. See docs-mobile/13-roadmap-mobile.md for
/// the note this corrects in the original wireframe.
enum ReportStatus {
  submitted,
  duplicateCheck,
  barangayReview,
  assigned,
  inProgress,
  completed,
  awaitingConfirmation,
  reopened,
  closed;

  String get label => switch (this) {
    ReportStatus.submitted => 'Submitted',
    ReportStatus.duplicateCheck => 'Checking for duplicates',
    ReportStatus.barangayReview => 'Barangay review',
    ReportStatus.assigned => 'Assigned',
    ReportStatus.inProgress => 'In progress',
    ReportStatus.completed => 'Work completed',
    ReportStatus.awaitingConfirmation => 'Awaiting your confirmation',
    ReportStatus.reopened => 'Reopened',
    ReportStatus.closed => 'Resolved',
  };

  StatusTone get tone => switch (this) {
    ReportStatus.submitted || ReportStatus.duplicateCheck => StatusTone.pending,
    ReportStatus.barangayReview ||
    ReportStatus.assigned ||
    ReportStatus.inProgress ||
    ReportStatus.reopened => StatusTone.progress,
    ReportStatus.completed ||
    ReportStatus.awaitingConfirmation => StatusTone.action,
    ReportStatus.closed => StatusTone.resolved,
  };

  bool get needsCitizenConfirmation =>
      this == ReportStatus.awaitingConfirmation;
}

/// Renamed from ReportPhotos — FR-20.2 made video an alternative to photo,
/// so "Photos" stopped describing what this actually holds.
class ReportMedia {
  const ReportMedia({
    this.citizenPhotoPaths = const [],
    this.citizenVideoPath,
    this.citizenVideoDurationSeconds,
    this.beforePhotoPath,
    this.afterPhotoPath,
  });

  /// FR-1.2 — one or more photos. FR-20.2 — mutually exclusive with
  /// citizenVideoPath in practice (a report has photos or a video, never
  /// both), but both independently populatable rather than a sealed choice:
  /// keeps this a plain data holder, and NewReportController is already the
  /// single place that enforces "exactly one kind of media."
  final List<String> citizenPhotoPaths;
  final String? citizenVideoPath;
  final int? citizenVideoDurationSeconds;
  final String? beforePhotoPath;
  final String? afterPhotoPath;

  bool get hasPhotos => citizenPhotoPaths.isNotEmpty;
  bool get hasVideo => citizenVideoPath != null;
}

class Report {
  const Report({
    required this.id,
    required this.trackingId,
    required this.categoryId,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.status,
    required this.createdAt,
    this.media = const ReportMedia(),
    this.confirmationCount = 0,
    this.verifiedAt,
    this.supportCount = 0,
    this.disputeCount = 0,
  });

  final String id;
  final String trackingId;
  final String categoryId;
  final String description;
  final double latitude;
  final double longitude;
  final String address;
  final ReportStatus status;
  final DateTime createdAt;
  final ReportMedia media;
  final int confirmationCount;

  /// FR-5.5/FR-19.1 — set once by Barangay Staff's Verify action, never
  /// cleared by later workflow states. Drives the "Verified" badge
  /// (FR-19.1) — never derive verification from `status` (FR-19.3).
  final DateTime? verifiedAt;
  bool get isVerified => verifiedAt != null;

  /// Aggregate reaction counts (FR-17.2) — visible to any viewer, embedded
  /// here rather than fetched per-report so a feed of many reports doesn't
  /// need a separate subscription per card. The *viewer's own* reaction is
  /// deliberately not embedded — see myReactionForReportProvider.
  final int supportCount;
  final int disputeCount;

  Report copyWith({
    ReportStatus? status,
    DateTime? verifiedAt,
    int? supportCount,
    int? disputeCount,
  }) => Report(
    id: id,
    trackingId: trackingId,
    categoryId: categoryId,
    description: description,
    latitude: latitude,
    longitude: longitude,
    address: address,
    status: status ?? this.status,
    createdAt: createdAt,
    media: media,
    confirmationCount: confirmationCount,
    verifiedAt: verifiedAt ?? this.verifiedAt,
    supportCount: supportCount ?? this.supportCount,
    disputeCount: disputeCount ?? this.disputeCount,
  );
}

/// Maps a report's current status onto the fixed pipeline for display —
/// presentation concern only, mirroring how docs-mobile/04 describes
/// Timeline as "renders a `List<WorkflowStepStatus>`", not workflow logic.
List<TimelineStepData> buildReportTimeline(ReportStatus status) {
  const order = [
    ReportStatus.submitted,
    ReportStatus.duplicateCheck,
    ReportStatus.barangayReview,
    ReportStatus.assigned,
    ReportStatus.inProgress,
    ReportStatus.completed,
    ReportStatus.awaitingConfirmation,
    ReportStatus.closed,
  ];
  final currentIndex = status == ReportStatus.reopened
      ? order.indexOf(ReportStatus.assigned)
      : order.indexOf(status);

  return [
    for (var i = 0; i < order.length; i++)
      TimelineStepData(
        title: order[i].label,
        state: i < currentIndex
            ? TimelineStepState.done
            : i == currentIndex
            ? TimelineStepState.current
            : TimelineStepState.pending,
      ),
  ];
}
