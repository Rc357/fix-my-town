import 'package:fixmytown_citizen/features/notifications/domain/app_notification.dart';

/// Vendor-independent contract — same pattern as ReportRepository/
/// CommentRepository.
abstract interface class NotificationRepository {
  /// The signed-in citizen's own notifications, newest first. A guest
  /// watching this should just see an empty list — there's no user_id to
  /// scope by.
  Stream<List<AppNotification>> watchNotifications();

  Future<void> markAsRead(String notificationId);
}
