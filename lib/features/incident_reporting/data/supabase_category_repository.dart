import 'package:flutter/material.dart';
import 'package:obserba/features/incident_reporting/domain/category_repository.dart';
import 'package:obserba/features/incident_reporting/domain/report_category.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Backed by report_category/category_group (see
/// .test_folder/supabase-setup-guide.md). RLS's tenant_isolation policy on
/// report_category means this only ever returns the caller's own
/// organization's catalog — no client-side org filter needed.
///
/// The schema has no icon column (icons are a client-side presentation
/// concern — see docs-mobile/04-design-system.md's "Icons" note on a future
/// custom icon font). `_iconFor` maps the seeded 25-category catalog by
/// name, falling back to a generic icon for anything it doesn't recognize —
/// e.g. a new category a City Hall Admin adds later (FR-11).
class SupabaseCategoryRepository implements CategoryRepository {
  SupabaseCategoryRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<List<ReportCategory>> fetchCategories() async {
    final rows = await _client
        .from('report_category')
        .select(
          'id, name, requires_emergency_escalation, category_group(sort_order, name)',
        )
        .eq('is_active', true);

    final withOrder = [
      for (final row in rows)
        (
          sortOrder:
              (row['category_group'] as Map<String, dynamic>?)?['sort_order']
                  as int? ??
              0,
          category: ReportCategory(
            id: row['id'] as String,
            label: row['name'] as String,
            icon: _iconFor(row['name'] as String),
            isPriority: (row['requires_emergency_escalation'] as bool?) ?? false,
          ),
        ),
    ]..sort((a, b) {
      final bySortOrder = a.sortOrder.compareTo(b.sortOrder);
      return bySortOrder != 0
          ? bySortOrder
          : a.category.label.compareTo(b.category.label);
    });

    return [for (final entry in withOrder) entry.category];
  }

  IconData _iconFor(String name) => switch (name) {
    'Potholes/Road Damage' => Icons.add_road,
    'Broken Streetlights' => Icons.lightbulb_outline,
    'Damaged Sidewalks' => Icons.directions_walk,
    'Drainage/Flooding Issues' => Icons.water,
    'Broken Public Facilities' => Icons.apartment_outlined,
    'Uncollected Garbage' => Icons.delete_outline,
    'Illegal Dumping' => Icons.block,
    'Sewage/Wastewater Issues' => Icons.water_drop_outlined,
    'Public Area Cleanliness' => Icons.cleaning_services_outlined,
    'Street Lighting Safety Concerns' => Icons.lightbulb_circle_outlined,
    'Noise Complaints' => Icons.volume_up_outlined,
    'Stray Animals' => Icons.pets_outlined,
    'Vandalism' => Icons.format_paint_outlined,
    'Illegal Structures' => Icons.domain_disabled_outlined,
    'Mosquito/Pest Breeding Sites' => Icons.bug_report_outlined,
    'Air/Water Pollution' => Icons.air,
    'Illegal Vending/Health Violations' => Icons.storefront_outlined,
    'Traffic Violations' => Icons.traffic,
    'Damaged Traffic Signs/Signals' => Icons.signpost_outlined,
    'Public Transport Complaints' => Icons.directions_bus_outlined,
    'Water Supply Issues' => Icons.water_drop_outlined,
    'Power Outage/Electrical Hazards' => Icons.bolt,
    'Internet/Telecom Infrastructure' => Icons.cell_tower_outlined,
    'Missing/Damaged Public Signage' => Icons.signpost_outlined,
    'Requests for Assistance' => Icons.volunteer_activism_outlined,
    _ => Icons.report_outlined,
  };
}
