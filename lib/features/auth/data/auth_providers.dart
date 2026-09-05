import 'package:fixmytown_citizen/features/auth/data/in_memory_auth_repository.dart';
import 'package:fixmytown_citizen/features/auth/domain/app_user.dart';
import 'package:fixmytown_citizen/features/auth/domain/auth_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final repository = InMemoryAuthRepository();
  ref.onDispose(repository.dispose);
  return repository;
});

final authStateProvider = StreamProvider<AppUser?>(
  (ref) => ref.watch(authRepositoryProvider).authStateChanges(),
);
