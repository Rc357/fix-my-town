import 'package:obserba/features/incident_reporting/domain/report.dart';
import 'package:obserba/features/incident_reporting/domain/report_reaction.dart';

/// FR-1.2/FR-20.2 — either one or more [photoPaths], or a single [videoPath],
/// never both, never neither; NewReportController is what actually enforces
/// that (canReview/hasMedia), this class just has room for either.
class NewReportDraft {
  const NewReportDraft({
    required this.categoryId,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.address,
    this.photoPaths = const [],
    this.videoPath,
    this.videoDurationSeconds,
    this.barangayId,
  });

  final String categoryId;
  final String description;
  final double latitude;
  final double longitude;
  final String address;
  final List<String> photoPaths;
  final String? videoPath;
  final int? videoDurationSeconds;

  /// The citizen's self-selected home barangay (AppUser.barangayId), passed
  /// through so report_before_insert's GPS-based resolve_barangay() has
  /// something to fall back to when it can't be resolved either way (no
  /// barangay_boundary polygon data exists yet — see
  /// .test_folder/supabase-setup-guide.md §8.1). Null for a guest, or a
  /// citizen who hasn't picked one yet.
  final String? barangayId;
}

/// Vendor-independent contract — mirrors AuthRepository's pattern (see
/// features/auth/domain/auth_repository.dart). The in-memory implementation
/// is a stand-in until the NestJS API (docs/08-api-specification.md) exists;
/// nothing above this interface should need to change when it's swapped in.
abstract interface class ReportRepository {
  Stream<List<Report>> watchNearby();

  Stream<List<Report>> watchMine();

  Future<Report?> findById(String id);

  Future<Report?> findByTrackingId(String trackingId);

  Future<Report> submit(NewReportDraft draft);

  Future<void> confirmResolved(String reportId);

  Future<void> dispute(String reportId);

  /// FR-17.1 — casts or replaces the caller's reaction on a report; a caller
  /// holds at most one reaction per report at a time. `reason` is required
  /// when `kind` is `ReactionKind.dispute` (FR-17.3).
  Future<void> react(String reportId, ReactionKind kind, {String? reason});

  /// Removes the caller's own reaction, if any.
  Future<void> removeReaction(String reportId);

  /// The caller's own reaction on a report, or null if they haven't reacted.
  /// Deliberately separate from the Report stream — see Report.supportCount's
  /// doc comment for why per-viewer state isn't embedded in the shared model.
  Future<ReactionKind?> myReaction(String reportId);

  /// Turns a `ReportMedia` path into something `Image.network`/a video
  /// player can actually load. A no-op for the in-memory adapter (already a
  /// local file path); for Supabase, a raw Storage object path needs a
  /// signed URL first since the bucket is private (see the setup guide).
  Future<String> resolveMediaUrl(String path);
}
