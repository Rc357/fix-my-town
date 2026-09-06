import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';

const _channelId = 'report_status';
const _channelName = 'Report status updates';
const _channel = AndroidNotificationChannel(
  _channelId,
  _channelName,
  description: "Notifies you when one of your reports' status changes.",
  importance: Importance.high,
);

/// Must be a top-level function, not a closure — FCM runs this on a
/// separate background isolate when a message arrives while the app isn't
/// in the foreground, and the Dart compiler needs the entry-point pragma to
/// keep it from being tree-shaken.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Deliberately minimal: the foreground listener below does the real work
  // (showing a local notification, routing on tap). Background delivery
  // just needs this isolate to exist for FCM to consider the message handled
  // — Android shows FCM's own notification tray entry automatically for a
  // background/terminated `notification` payload, no local-notifications
  // call needed here too.
}

/// Turns Firebase Cloud Messaging into an actually-visible notification and
/// a deep link — per docs-mobile/07-device-capabilities.md's push section:
/// permission request, foreground display via flutter_local_notifications
/// (FCM does not show a heads-up notification on its own while the app is
/// foregrounded), and routing a tapped notification's `data['route']` into
/// go_router.
///
/// Deliberately not done here (see the setup guide's "what's deliberately
/// not here"): nothing registers the fetched FCM token against a backend —
/// there's no device-token endpoint yet for it to register against.
class PushNotificationService {
  PushNotificationService(this._logger);

  final Logger _logger;
  final _localNotifications = FlutterLocalNotificationsPlugin();
  GoRouter? _router;
  bool _initialized = false;

  Future<void> init(GoRouter router) async {
    if (_initialized) return;
    _initialized = true;
    _router = router;

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    final settings = await FirebaseMessaging.instance.requestPermission();
    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      _logger.i('Push notification permission denied — continuing without it.');
      return;
    }

    await _localNotifications.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
      onDidReceiveNotificationResponse: (response) {
        final route = response.payload;
        if (route != null) _router?.go(route);
      },
    );
    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_channel);

    FirebaseMessaging.onMessage.listen(_showForegroundNotification);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    // App launched by tapping a notification from a fully terminated state.
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) _handleNotificationTap(initialMessage);

    try {
      final token = await FirebaseMessaging.instance.getToken();
      _logger.i('FCM token acquired: $token');
    } catch (error, stackTrace) {
      _logger.e(
        'Failed to fetch FCM token',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> _showForegroundNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;
    await _localNotifications.show(
      id: message.hashCode,
      title: notification.title,
      body: notification.body,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(_channelId, _channelName),
        iOS: DarwinNotificationDetails(),
      ),
      payload: message.data['route'] as String?,
    );
  }

  void _handleNotificationTap(RemoteMessage message) {
    final route = message.data['route'] as String?;
    if (route != null) _router?.go(route);
  }
}
