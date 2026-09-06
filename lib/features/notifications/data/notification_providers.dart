import 'package:fixmytown_citizen/features/notifications/data/push_notification_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

final pushNotificationServiceProvider = Provider<PushNotificationService>(
  (ref) => PushNotificationService(Logger()),
);
