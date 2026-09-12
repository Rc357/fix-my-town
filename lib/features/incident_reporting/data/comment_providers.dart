import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:obserba/app/config/app_config.dart';
import 'package:obserba/features/auth/data/auth_providers.dart';
import 'package:obserba/features/incident_reporting/data/in_memory_comment_repository.dart';
import 'package:obserba/features/incident_reporting/data/supabase_comment_repository.dart';
import 'package:obserba/features/incident_reporting/domain/comment.dart';
import 'package:obserba/features/incident_reporting/domain/comment_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final commentRepositoryProvider = Provider<CommentRepository>((ref) {
  final config = ref.watch(appConfigProvider);
  if (config.hasSupabase) {
    return SupabaseCommentRepository(Supabase.instance.client);
  }
  final repository = InMemoryCommentRepository(
    currentUserId: () => ref.read(authRepositoryProvider).currentUser?.id,
    currentUsername: () => ref.read(authRepositoryProvider).currentUser?.username,
  );
  ref.onDispose(repository.dispose);
  return repository;
});

final commentsForReportProvider = StreamProvider.family<List<Comment>, String>(
  (ref, reportId) => ref.watch(commentRepositoryProvider).watchComments(reportId),
);
