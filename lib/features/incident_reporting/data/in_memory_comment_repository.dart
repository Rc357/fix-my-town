import 'dart:async';
import 'dart:math';

import 'package:fixmytown_citizen/features/incident_reporting/domain/comment.dart';
import 'package:fixmytown_citizen/features/incident_reporting/domain/comment_repository.dart';

/// Backend-free adapter, same pattern as InMemoryReportRepository. Flagging
/// is accepted but goes nowhere — there's no Barangay Staff review-queue UI
/// in this app to surface it to (see Comment.isHidden's doc comment).
class InMemoryCommentRepository implements CommentRepository {
  InMemoryCommentRepository({
    required String? Function() currentUserId,
    required String? Function() currentUsername,
  }) : _currentUserId = currentUserId,
       _currentUsername = currentUsername;

  final String? Function() _currentUserId;
  final String? Function() _currentUsername;
  final _commentsByReport = <String, List<Comment>>{};
  final _controller = StreamController<void>.broadcast();
  final _random = Random();

  @override
  Stream<List<Comment>> watchComments(String reportId) async* {
    List<Comment> current() => List.unmodifiable(_commentsByReport[reportId] ?? const []);
    yield current();
    yield* _controller.stream.map((_) => current());
  }

  @override
  Future<Comment> postComment(String reportId, String body) async {
    final userId = _currentUserId();
    final username = _currentUsername();
    if (userId == null || username == null) {
      throw StateError('Sign in with a username before commenting.');
    }
    if (body.trim().isEmpty) {
      throw ArgumentError('Comment cannot be empty.');
    }
    await Future<void>.delayed(const Duration(milliseconds: 150));
    final comment = Comment(
      id: 'c-${_random.nextInt(1 << 32)}',
      reportId: reportId,
      authorUserId: userId,
      authorUsername: username,
      body: body.trim(),
      createdAt: DateTime.now(),
    );
    (_commentsByReport[reportId] ??= []).add(comment);
    _controller.add(null);
    return comment;
  }

  @override
  Future<void> flagComment(String commentId, String reason) async {
    // No-op beyond acknowledging the call — see class doc comment.
    await Future<void>.delayed(const Duration(milliseconds: 100));
  }

  void dispose() => _controller.close();
}
