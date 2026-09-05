import 'package:aninag_citizen/app/widgets/status_chip.dart';
import 'package:aninag_citizen/app/widgets/workflow_timeline.dart';

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

class ReportPhotos {
  const ReportPhotos({
    this.citizenPhotoPath,
    this.beforePhotoPath,
    this.afterPhotoPath,
  });

  final String? citizenPhotoPath;
  final String? beforePhotoPath;
  final String? afterPhotoPath;
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
    this.photos = const ReportPhotos(),
    this.confirmationCount = 0,
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
  final ReportPhotos photos;
  final int confirmationCount;

  Report copyWith({ReportStatus? status}) => Report(
    id: id,
    trackingId: trackingId,
    categoryId: categoryId,
    description: description,
    latitude: latitude,
    longitude: longitude,
    address: address,
    status: status ?? this.status,
    createdAt: createdAt,
    photos: photos,
    confirmationCount: confirmationCount,
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
