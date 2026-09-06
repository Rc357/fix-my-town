import 'package:fixmytown_citizen/features/auth/domain/barangay.dart';
import 'package:fixmytown_citizen/features/auth/domain/barangay_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Backed by the `barangay` table (.test_folder/supabase-setup-guide.md
/// §8.1). RLS's tenant_isolation policy scopes this to the caller's own
/// organization already — no client-side org filter needed.
class SupabaseBarangayRepository implements BarangayRepository {
  SupabaseBarangayRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<List<Barangay>> fetchBarangays() async {
    final rows = await _client.from('barangay').select('id, name').order('name');
    return [
      for (final row in rows)
        Barangay(id: row['id'] as String, name: row['name'] as String),
    ];
  }
}
