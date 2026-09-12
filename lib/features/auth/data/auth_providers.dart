import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:obserba/app/config/app_config.dart';
import 'package:obserba/features/auth/data/in_memory_auth_repository.dart';
import 'package:obserba/features/auth/data/in_memory_barangay_repository.dart';
import 'package:obserba/features/auth/data/supabase_auth_repository.dart';
import 'package:obserba/features/auth/data/supabase_barangay_repository.dart';
import 'package:obserba/features/auth/domain/app_user.dart';
import 'package:obserba/features/auth/domain/auth_repository.dart';
import 'package:obserba/features/auth/domain/barangay.dart';
import 'package:obserba/features/auth/domain/barangay_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Real Supabase Auth once configured (see AppConfig.hasSupabase); falls
/// back to the in-memory demo adapter otherwise, so the app keeps running
/// without credentials — same guarantee the README makes for Firebase.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final config = ref.watch(appConfigProvider);
  if (config.hasSupabase) {
    return SupabaseAuthRepository(Supabase.instance.client);
  }
  final repository = InMemoryAuthRepository();
  ref.onDispose(repository.dispose);
  return repository;
});

final authStateProvider = StreamProvider<AppUser?>(
  (ref) => ref.watch(authRepositoryProvider).authStateChanges(),
);

/// Same fallback pattern as authRepositoryProvider.
final barangayRepositoryProvider = Provider<BarangayRepository>((ref) {
  final config = ref.watch(appConfigProvider);
  if (config.hasSupabase) {
    return SupabaseBarangayRepository(Supabase.instance.client);
  }
  return InMemoryBarangayRepository();
});

/// The tenant's barangay list — a one-shot fetch cached for the session,
/// same reasoning as categoriesProvider.
final barangaysProvider = FutureProvider<List<Barangay>>(
  (ref) => ref.watch(barangayRepositoryProvider).fetchBarangays(),
);
