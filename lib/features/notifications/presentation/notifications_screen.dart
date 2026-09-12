import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:obserba/app/theme/obs_colors.dart';
import 'package:obserba/app/theme/obs_spacing.dart';
import 'package:obserba/app/theme/obs_text_styles.dart';
import 'package:obserba/app/widgets/app_bottom_nav.dart';
import 'package:obserba/features/notifications/data/notification_providers.dart';
import 'package:obserba/features/notifications/domain/app_notification.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: SafeArea(
        child: notificationsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Center(
            child: Padding(
              padding: const EdgeInsets.all(ObsSpace.xl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Couldn't load notifications: $error",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: ObsColors.muted),
                  ),
                  const SizedBox(height: ObsSpace.md),
                  OutlinedButton(
                    onPressed: () => ref.invalidate(notificationsProvider),
                    child: const Text('Try again'),
                  ),
                ],
              ),
            ),
          ),
          data: (notifications) => RefreshIndicator(
            onRefresh: () async => ref.invalidate(notificationsProvider),
            child: notifications.isEmpty
                ? ListView(
                    // A ListView (not a Center) so pull-to-refresh still
                    // works on an empty list — same reasoning as the home
                    // feed's empty state.
                    padding: const EdgeInsets.only(top: 120),
                    children: [
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: ObsSpace.xl),
                          child: Text(
                            "You'll see activity on your reports here — "
                            'reactions, comments, verification, and status '
                            'updates.\n\nPull down to refresh.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: ObsColors.muted),
                          ),
                        ),
                      ),
                    ],
                  )
                : ListView.separated(
                    itemCount: notifications.length,
                    separatorBuilder: (context, index) => const Divider(height: 1),
                    itemBuilder: (context, index) =>
                        _NotificationTile(notification: notifications[index]),
                  ),
          ),
        ),
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 2),
    );
  }
}

class _NotificationTile extends ConsumerWidget {
  const _NotificationTile({required this.notification});

  final AppNotification notification;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      tileColor: notification.isRead ? null : ObsColors.brandTint,
      leading: Icon(_iconFor(notification.kind), color: ObsColors.brand),
      title: Text(notification.body, style: const TextStyle(fontSize: ObsFontSize.lg)),
      subtitle: Text(
        _relativeTime(notification.createdAt),
        style: TextStyle(fontSize: ObsFontSize.sm, color: ObsColors.muted),
      ),
      onTap: () async {
        await ref.read(notificationRepositoryProvider).markAsRead(notification.id);
        ref.invalidate(notificationsProvider);
        if (context.mounted) {
          unawaited(context.push('/reports/${notification.reportId}'));
        }
      },
    );
  }

  IconData _iconFor(NotificationKind kind) => switch (kind) {
    NotificationKind.reaction => Icons.thumb_up_alt_outlined,
    NotificationKind.comment => Icons.mode_comment_outlined,
    NotificationKind.verified => Icons.verified_outlined,
    NotificationKind.statusChange => Icons.timeline_outlined,
  };

  String _relativeTime(DateTime createdAt) {
    final minutes = DateTime.now().difference(createdAt).inMinutes;
    return switch (minutes) {
      < 1 => 'Just now',
      < 60 => '${minutes}m ago',
      < 60 * 24 => '${minutes ~/ 60}h ago',
      _ => '${minutes ~/ (60 * 24)}d ago',
    };
  }
}
