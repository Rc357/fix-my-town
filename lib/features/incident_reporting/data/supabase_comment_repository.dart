import 'package:fixmytown_citizen/features/incident_reporting/domain/comment.dart';
import 'package:fixmytown_citizen/features/incident_reporting/domain/comment_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Backed by report_comment/comment_flag (.test_folder/supabase-setup-guide.md).
/// `report_comment.user_id` has no FK to a denormalized username column, so
/// this joins `user_account` for the author's public identity on every read
/// — never `display_name`, always `username` (FR-16.2).
///
/// The join must use `user_account!report_comment_user_id_fkey(...)`, not a
/// bare `user_account(...)` — `report_comment` has a *second* FK into
/// user_account (`hidden_by_user_id`), so PostgREST can't infer which
/// relationship to embed without the explicit constraint name (PGRST201,
/// "more than one relationship was found").
class SupabaseCommentRepository implements CommentRepository {
  SupabaseCommentRepository(this._client);

  final SupabaseClient _client;
  static const _table = 'report_comment';

  @override
  Stream<List<Comment>> watchComments(String reportId) =>
      // A one-shot fetch wrapped in a Stream, not realtime .stream() — same
      // reliability fix applied to SupabaseNotificationRepository: a
      // realtime channel that never confirms its subscription just never
      // emits, with no timeout, which is exactly what left this section
      // stuck on a loading spinner. report_detail_screen.dart invalidates
      // commentsForReportProvider after posting a comment to make the new
      // one show up immediately, since there's no push update anymore.
      Stream.fromFuture(_fetchWithAuthors(reportId));

  Future<List<Comment>> _fetchWithAuthors(String reportId) async {
    final rows = await _client
        .from(_table)
        .select('*, user_account!report_comment_user_id_fkey(username)')
        .eq('report_id', reportId)
        .eq('is_hidden', false)
        .order('created_at');
    return [for (final row in rows) _toComment(row)];
  }

  @override
  Future<Comment> postComment(String reportId, String body) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw StateError('Sign in with a username before commenting.');
    }
    if (body.trim().isEmpty) {
      throw ArgumentError('Comment cannot be empty.');
    }
    final inserted = await _client
        .from(_table)
        .insert({'report_id': reportId, 'user_id': userId, 'body': body.trim()})
        .select('*, user_account!report_comment_user_id_fkey(username)')
        .single();
    return _toComment(inserted);
  }

  @override
  Future<void> flagComment(String commentId, String reason) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw StateError('Sign in before flagging a comment.');
    }
    await _client.from('comment_flag').insert({
      'comment_id': commentId,
      'flagged_by_user_id': userId,
      'reason': reason,
    });
  }

  Comment _toComment(Map<String, dynamic> row) {
    final author = row['user_account'] as Map<String, dynamic>?;
    return Comment(
      id: row['id'] as String,
      reportId: row['report_id'] as String,
      authorUserId: row['user_id'] as String,
      authorUsername: (author?['username'] as String?) ?? 'Citizen',
      body: row['body'] as String,
      createdAt: DateTime.parse(row['created_at'] as String),
      isHidden: (row['is_hidden'] as bool?) ?? false,
    );
  }
}
