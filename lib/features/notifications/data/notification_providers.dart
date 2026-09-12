import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:obserba/app/config/app_config.dart';
import 'package:obserba/features/notifications/data/in_memory_notification_repository.dart';
import 'package:obserba/features/notifications/data/push_notification_service.dart';
import 'package:obserba/features/notifications/data/supabase_notification_repository.dart';
import 'package:obserba/features/notifications/domain/app_notification.dart';
import 'package:obserba/features/notifications/domain/notification_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final pushNotificationServiceProvider = Provider<PushNotificationService>(
  (ref) => PushNotificationService(Logger()),
);

/// Same fallback pattern as reportRepositoryProvider/authRepositoryProvider.
final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  final config = ref.watch(appConfigProvider);
  if (config.hasSupabase) {
    return SupabaseNotificationRepository(Supabase.instance.client);
  }
  final repository = InMemoryNotificationRepository();
  ref.onDispose(repository.dispose);
  return repository;
});

final notificationsProvider = StreamProvider<List<AppNotification>>(
  (ref) => ref.watch(notificationRepositoryProvider).watchNotifications(),
);

/// Drives the bottom-nav badge — kept as a separate provider (rather than
/// having the badge widget re-derive this from notificationsProvider itself)
/// so it reads the same way anywhere else an unread count might be needed.
final unreadNotificationCountProvider = Provider<int>((ref) {
  final notifications = ref.watch(notificationsProvider).value ?? const [];
  return notifications.where((n) => !n.isRead).length;
});
