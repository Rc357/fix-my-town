import 'package:obserba/features/auth/domain/barangay.dart';
import 'package:obserba/features/auth/domain/barangay_repository.dart';

/// Demo data for when there's no Supabase backend configured — same role as
/// InMemoryCategoryRepository.
class InMemoryBarangayRepository implements BarangayRepository {
  @override
  Future<List<Barangay>> fetchBarangays() async => const [
    Barangay(id: 'demo-brgy-1', name: 'Barangay San Isidro'),
    Barangay(id: 'demo-brgy-2', name: 'Barangay Santo Niño'),
    Barangay(id: 'demo-brgy-3', name: 'Barangay Poblacion'),
  ];
}
