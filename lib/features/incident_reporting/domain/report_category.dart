import 'package:flutter/material.dart';

/// A citizen-facing incident category (FR-15) — tenant-configured data
/// (FR-11), fetched via CategoryRepository, never hardcoded. See
/// docs-mobile/13-roadmap-mobile.md's "category list must be fetched, never
/// hardcoded" note — this used to be a static list here; it isn't anymore.
class ReportCategory {
  const ReportCategory({
    required this.id,
    required this.label,
    required this.icon,
    this.isPriority = false,
  });

  final String id;
  final String label;
  final IconData icon;

  /// Fire/Crime-style categories that skip the standard queue per FR-4.3 —
  /// backed by report_category.requires_emergency_escalation.
  final bool isPriority;
}

/// Shown in place of a real category while the catalog is still loading, or
/// for a categoryId that isn't in it (e.g. a since-deactivated category on
/// an older report) — never a crash, never a blank tile.
ReportCategory unknownCategory(String id) =>
    ReportCategory(id: id, label: 'Category', icon: Icons.help_outline);

extension ReportCategoryLookup on List<ReportCategory> {
  ReportCategory byId(String id) =>
      firstWhere((c) => c.id == id, orElse: () => unknownCategory(id));
}
