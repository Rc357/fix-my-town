import 'package:obserba/features/incident_reporting/domain/comment.dart';

/// FR-18. Separate from ReportRepository — comments are a genuinely
/// independent resource (their own list, their own pagination-shaped access
/// pattern) rather than a property of a single report the way reactions are.
abstract interface class CommentRepository {
  Stream<List<Comment>> watchComments(String reportId);

  /// Verified Citizen only (FR-18.1) — callers must be signed in; enforced
  /// by the repository implementation (in-memory: throws if signed out;
  /// Supabase: RLS's own_write policy requires user_id = auth.uid()).
  Future<Comment> postComment(String reportId, String body);

  /// FR-18.2 — any viewer, including Guests, may flag a comment.
  Future<void> flagComment(String commentId, String reason);
}
