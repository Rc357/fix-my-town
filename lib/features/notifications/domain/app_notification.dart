import 'package:obserba/features/incident_reporting/domain/report.dart';
import 'package:obserba/features/incident_reporting/domain/report_reaction.dart';

/// The in-app notification list's item — distinct from FCM push
/// (PushNotificationService), which is an ephemeral OS-tray alert. This is
/// the browsable history, same distinction Instagram/Facebook draw between
/// a push alert and their notifications tab.
enum NotificationKind { reaction, comment, verified, statusChange }

class AppNotification {
  const AppNotification({
    required this.id,
    required this.kind,
    required this.reportId,
    required this.isRead,
    required this.createdAt,
    this.actorUsername,
    this.reactionKind,
    this.newState,
  });

  final String id;
  final NotificationKind kind;
  final String reportId;
  final bool isRead;
  final DateTime createdAt;

  /// Who caused this (reaction/comment) — null for system-driven kinds
  /// (verified/statusChange), which have no single "actor."
  final String? actorUsername;

  /// Set only when kind == reaction.
  final ReactionKind? reactionKind;

  /// Set only when kind == statusChange.
  final ReportStatus? newState;

  /// Display text — built client-side from structured facts (kind, actor,
  /// reaction/state) rather than a pre-rendered string from the database,
  /// so it reuses ReportStatus.label the same way every other screen does
  /// instead of duplicating that formatting in SQL.
  String get body => switch (kind) {
    NotificationKind.reaction =>
      '${actorUsername ?? 'Someone'} '
      '${reactionKind == ReactionKind.support ? 'supported' : 'disputed'} '
      'your report',
    NotificationKind.comment => '${actorUsername ?? 'Someone'} commented on your report',
    NotificationKind.verified => 'Your report was verified',
    NotificationKind.statusChange =>
      'Your report is now ${newState?.label ?? 'updated'}',
  };
}
