import 'package:obserba/features/incident_reporting/domain/report.dart';
import 'package:obserba/features/incident_reporting/domain/report_reaction.dart';
import 'package:obserba/features/notifications/domain/app_notification.dart';
import 'package:obserba/features/notifications/domain/notification_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Backed by the `notification` table (.test_folder/supabase-setup-guide.md
/// §11) — populated entirely by triggers on report_reaction/report_comment/
/// report, never written to directly here except markAsRead.
///
/// A one-shot fetch wrapped in a Stream, not realtime `.stream()` — same
/// choice SupabaseReportRepository.watchNearby/watchMine already makes, for
/// the same reliability reason: a realtime channel that never confirms its
/// subscription (misconfigured publication, a transient connection issue)
/// just never emits anything, with no timeout, leaving the UI stuck on a
/// loading spinner forever. A plain query either returns data or throws —
/// it can't get stuck in limbo. Traded deliberately: pull-to-refresh
/// (NotificationsScreen invalidates notificationsProvider) replaces instant
/// push updates, same tradeoff as the report feed.
class SupabaseNotificationRepository implements NotificationRepository {
  SupabaseNotificationRepository(this._client);

  final SupabaseClient _client;
  static const _table = 'notification';

  @override
  Stream<List<AppNotification>> watchNotifications() =>
      Stream.fromFuture(_fetchNotifications());

  Future<List<AppNotification>> _fetchNotifications() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return const [];
    final rows = await _client
        .from(_table)
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    return [for (final row in rows) _toNotification(row)];
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    await _client
        .from(_table)
        .update({'is_read': true})
        .eq('id', notificationId);
  }

  AppNotification _toNotification(Map<String, dynamic> row) {
    final kind = switch (row['kind'] as String) {
      'reaction' => NotificationKind.reaction,
      'comment' => NotificationKind.comment,
      'verified' => NotificationKind.verified,
      _ => NotificationKind.statusChange,
    };
    final reactionKindRaw = row['reaction_kind'] as String?;
    final newStateRaw = row['new_state_code'] as String?;
    return AppNotification(
      id: row['id'] as String,
      kind: kind,
      reportId: row['report_id'] as String,
      actorUsername: row['actor_username'] as String?,
      reactionKind: reactionKindRaw == null
          ? null
          : ReactionKind.values.byName(reactionKindRaw),
      newState: newStateRaw == null
          ? null
          : ReportStatus.values.byName(newStateRaw),
      isRead: row['is_read'] as bool,
      createdAt: DateTime.parse(row['created_at'] as String),
    );
  }
}
