import 'package:fixmytown_citizen/features/auth/domain/barangay.dart';

/// Vendor-independent contract — same pattern as CategoryRepository/
/// ReportRepository.
abstract interface class BarangayRepository {
  /// The tenant's barangay list, ordered by name. A one-shot fetch, same
  /// reasoning as CategoryRepository.fetchCategories — this changes rarely
  /// enough that nothing here needs a stream.
  Future<List<Barangay>> fetchBarangays();
}
