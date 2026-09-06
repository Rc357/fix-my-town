import 'package:fixmytown_citizen/features/incident_reporting/domain/category_repository.dart';
import 'package:fixmytown_citizen/features/incident_reporting/domain/report_category.dart';
import 'package:flutter/material.dart';

/// Demo data for when there's no Supabase backend configured — same role as
/// InMemoryReportRepository/InMemoryAuthRepository. Not the real 25-category
/// seed catalog (that lives in the database) — just enough variety to
/// exercise the category picker without a backend.
class InMemoryCategoryRepository implements CategoryRepository {
  @override
  Future<List<ReportCategory>> fetchCategories() async => _demoCategories;
}

const _demoCategories = <ReportCategory>[
  ReportCategory(id: 'broken_road', label: 'Broken road', icon: Icons.add_road),
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
  ReportCategory(id: 'electric_wires', label: 'Electric wires', icon: Icons.bolt),
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
