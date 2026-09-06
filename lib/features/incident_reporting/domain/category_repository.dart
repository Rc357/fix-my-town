import 'package:fixmytown_citizen/features/incident_reporting/domain/report_category.dart';

/// Vendor-independent contract — same pattern as ReportRepository/
/// AuthRepository (see features/auth/domain/auth_repository.dart).
abstract interface class CategoryRepository {
  /// The tenant's active category catalog (FR-11/FR-15), ordered by group
  /// then name. A one-shot fetch, not a stream — categories change rarely
  /// enough within a session that nothing here needs pull-to-refresh or
  /// live updates, unlike the report feed.
  Future<List<ReportCategory>> fetchCategories();
}
