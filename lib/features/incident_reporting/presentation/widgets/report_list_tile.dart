import 'package:aninag_citizen/app/widgets/report_card.dart';
import 'package:aninag_citizen/app/widgets/status_chip.dart';
import 'package:aninag_citizen/features/incident_reporting/domain/report.dart';
import 'package:aninag_citizen/features/incident_reporting/domain/report_category.dart';
import 'package:flutter/material.dart';

/// Maps a Report onto ReportCard consistently everywhere a report appears
/// in a list (Home feed, My Reports) — one place that decides "status color
/// wins over category color" for the stripe/icon tint, per the mockup.
class ReportListTile extends StatelessWidget {
  const ReportListTile({required this.report, required this.onTap, super.key});

  final Report report;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final category = ReportCategories.byId(report.categoryId);
    final (background, foreground) = statusToneColors(report.status.tone);

    return ReportCard(
      icon: category.icon,
      iconColor: foreground,
      iconBackground: background,
      stripeColor: foreground,
      title: category.label,
      meta: _metaLine(report),
      statusLabel: report.status.label,
      statusTone: report.status.tone,
      onTap: onTap,
    );
  }

  String _metaLine(Report report) {
    final minutes = DateTime.now().difference(report.createdAt).inMinutes;
    final relative = switch (minutes) {
      < 60 => '${minutes}m ago',
      < 60 * 24 => '${minutes ~/ 60}h ago',
      _ => '${minutes ~/ (60 * 24)}d ago',
    };
    return '${report.trackingId} · $relative';
  }
}
