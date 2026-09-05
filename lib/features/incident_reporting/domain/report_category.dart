import 'package:flutter/material.dart';

/// The MVP category list from docs/03-prd.md. In a real deployment this is
/// tenant-configured data fetched from the backend (FR-11) — kept as a
/// static list here only because there's no backend yet. See
/// docs-mobile/13-roadmap-mobile.md's "category list must be fetched, never
/// hardcoded" note: swap this for an API-backed provider before onboarding a
/// second city, not before.
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

  /// Fire/Crime — skips the standard queue per FR-4.3.
  final bool isPriority;
}

abstract final class ReportCategories {
  static const all = <ReportCategory>[
    ReportCategory(
      id: 'broken_road',
      label: 'Broken road',
      icon: Icons.add_road,
    ),
    ReportCategory(id: 'flooding', label: 'Flooding', icon: Icons.water),
    ReportCategory(id: 'garbage', label: 'Garbage', icon: Icons.delete_outline),
    ReportCategory(
      id: 'illegal_dumping',
      label: 'Illegal dumping',
      icon: Icons.block,
    ),
    ReportCategory(
      id: 'fallen_tree',
      label: 'Fallen tree',
      icon: Icons.park_outlined,
    ),
    ReportCategory(
      id: 'street_light',
      label: 'Street light',
      icon: Icons.lightbulb_outline,
    ),
    ReportCategory(
      id: 'electric_wires',
      label: 'Electric wires',
      icon: Icons.bolt,
    ),
    ReportCategory(
      id: 'water_leak',
      label: 'Water leak',
      icon: Icons.water_drop_outlined,
    ),
    ReportCategory(id: 'drainage', label: 'Drainage', icon: Icons.waves),
    ReportCategory(id: 'traffic', label: 'Traffic', icon: Icons.traffic),
    ReportCategory(
      id: 'facility_damage',
      label: 'Facility damage',
      icon: Icons.apartment_outlined,
    ),
    ReportCategory(
      id: 'crime',
      label: 'Crime',
      icon: Icons.local_police_outlined,
      isPriority: true,
    ),
    ReportCategory(
      id: 'fire',
      label: 'Fire',
      icon: Icons.local_fire_department_outlined,
      isPriority: true,
    ),
    ReportCategory(id: 'other', label: 'Other', icon: Icons.more_horiz),
  ];

  static ReportCategory byId(String id) =>
      all.firstWhere((c) => c.id == id, orElse: () => all.last);
}
