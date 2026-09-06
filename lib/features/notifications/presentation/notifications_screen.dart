import 'dart:async';

import 'package:fixmytown_citizen/app/theme/fmt_colors.dart';
import 'package:fixmytown_citizen/app/theme/fmt_spacing.dart';
import 'package:fixmytown_citizen/app/theme/fmt_text_styles.dart';
import 'package:fixmytown_citizen/app/widgets/app_bottom_nav.dart';
import 'package:fixmytown_citizen/features/notifications/data/notification_providers.dart';
import 'package:fixmytown_citizen/features/notifications/domain/app_notification.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
              padding: const EdgeInsets.all(FmtSpace.xl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Couldn't load notifications: $error",
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: FmtColors.muted),
                  ),
                  const SizedBox(height: FmtSpace.md),
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
                    children: const [
                      Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: FmtSpace.xl),
                          child: Text(
                            "You'll see activity on your reports here — "
                            'reactions, comments, verification, and status '
                            'updates.\n\nPull down to refresh.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: FmtColors.muted),
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
      tileColor: notification.isRead ? null : FmtColors.brandTint,
      leading: Icon(_iconFor(notification.kind), color: FmtColors.brand),
      title: Text(notification.body, style: const TextStyle(fontSize: FmtFontSize.lg)),
      subtitle: Text(
        _relativeTime(notification.createdAt),
        style: const TextStyle(fontSize: FmtFontSize.sm, color: FmtColors.muted),
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
