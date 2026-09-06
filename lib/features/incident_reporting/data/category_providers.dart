import 'package:fixmytown_citizen/app/config/app_config.dart';
import 'package:fixmytown_citizen/features/incident_reporting/data/in_memory_category_repository.dart';
import 'package:fixmytown_citizen/features/incident_reporting/data/supabase_category_repository.dart';
import 'package:fixmytown_citizen/features/incident_reporting/domain/category_repository.dart';
import 'package:fixmytown_citizen/features/incident_reporting/domain/report_category.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Same fallback pattern as reportRepositoryProvider/authRepositoryProvider:
/// real Supabase once configured, in-memory demo data otherwise.
final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  final config = ref.watch(appConfigProvider);
  if (config.hasSupabase) {
    return SupabaseCategoryRepository(Supabase.instance.client);
  }
  return InMemoryCategoryRepository();
});

/// The tenant's category catalog — a one-shot fetch cached for the rest of
/// the session (nothing here ever invalidates it; categories don't change
/// often enough to need pull-to-refresh).
final categoriesProvider = FutureProvider<List<ReportCategory>>(
  (ref) => ref.watch(categoryRepositoryProvider).fetchCategories(),
);
