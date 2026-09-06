import 'package:fixmytown_citizen/app/widgets/report_card.dart';
import 'package:fixmytown_citizen/app/widgets/status_chip.dart';
import 'package:fixmytown_citizen/features/incident_reporting/data/category_providers.dart';
import 'package:fixmytown_citizen/features/incident_reporting/domain/report.dart';
import 'package:fixmytown_citizen/features/incident_reporting/domain/report_category.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Maps a Report onto ReportCard consistently everywhere a report appears
/// in a list (Home feed, My Reports) — one place that decides "status color
/// wins over category color" for the stripe/icon tint, per the mockup.
class ReportListTile extends ConsumerWidget {
  const ReportListTile({required this.report, required this.onTap, super.key});

  final Report report;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final category =
        categoriesAsync.value?.byId(report.categoryId) ??
        unknownCategory(report.categoryId);
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
      isVerified: report.isVerified,
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
