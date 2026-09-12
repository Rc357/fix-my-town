import 'dart:async';

import 'package:obserba/features/incident_reporting/domain/report.dart';
import 'package:obserba/features/incident_reporting/domain/report_reaction.dart';
import 'package:obserba/features/notifications/domain/app_notification.dart';
import 'package:obserba/features/notifications/domain/notification_repository.dart';

/// Demo data for when there's no Supabase backend configured — same role as
/// InMemoryReportRepository. Matches that repository's seed-1/seed-2/seed-3
/// reports so tapping a notification's report actually resolves to
/// something real in demo mode.
class InMemoryNotificationRepository implements NotificationRepository {
  final _notifications = <AppNotification>[
    AppNotification(
      id: 'notif-1',
      kind: NotificationKind.verified,
      reportId: 'seed-1',
      isRead: false,
      createdAt: DateTime.now().subtract(const Duration(hours: 20)),
    ),
    AppNotification(
      id: 'notif-2',
      kind: NotificationKind.reaction,
      reportId: 'seed-2',
      actorUsername: 'juan_dc',
      reactionKind: ReactionKind.support,
      isRead: false,
      createdAt: DateTime.now().subtract(const Duration(hours: 4)),
    ),
    AppNotification(
      id: 'notif-3',
      kind: NotificationKind.comment,
      reportId: 'seed-2',
      actorUsername: 'maria_s',
      isRead: true,
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
    ),
    AppNotification(
      id: 'notif-4',
      kind: NotificationKind.statusChange,
      reportId: 'seed-3',
      newState: ReportStatus.closed,
      isRead: true,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];

  final _controller = StreamController<void>.broadcast();

  @override
  Stream<List<AppNotification>> watchNotifications() async* {
    yield List.unmodifiable(_notifications);
    yield* _controller.stream.map((_) => List.unmodifiable(_notifications));
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index == -1 || _notifications[index].isRead) return;
    final n = _notifications[index];
    _notifications[index] = AppNotification(
      id: n.id,
      kind: n.kind,
      reportId: n.reportId,
      isRead: true,
      createdAt: n.createdAt,
      actorUsername: n.actorUsername,
      reactionKind: n.reactionKind,
      newState: n.newState,
    );
    _controller.add(null);
  }

  void dispose() => _controller.close();
}
