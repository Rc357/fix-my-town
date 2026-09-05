import 'package:fixmytown_citizen/features/auth/data/auth_providers.dart';
import 'package:fixmytown_citizen/features/auth/data/in_memory_auth_repository.dart';
import 'package:fixmytown_citizen/features/auth/presentation/auth_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('signIn updates the repository and completes successfully', () async {
    final repository = InMemoryAuthRepository();
    final container = ProviderContainer(
      overrides: [authRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(() {
      container.dispose();
      repository.dispose();
    });

    await container.read(authControllerProvider.future);
    await container
        .read(authControllerProvider.notifier)
        .signIn(email: 'developer@example.com', password: 'password123');

    expect(repository.currentUser?.email, 'developer@example.com');
    expect(container.read(authControllerProvider), isA<AsyncData<void>>());
  });

  test('signIn exposes validation failures as AsyncError', () async {
    final repository = InMemoryAuthRepository();
    final container = ProviderContainer(
      overrides: [authRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(() {
      container.dispose();
      repository.dispose();
    });

    await container.read(authControllerProvider.future);
    await container
        .read(authControllerProvider.notifier)
        .signIn(email: 'invalid', password: 'short');

    expect(container.read(authControllerProvider), isA<AsyncError<void>>());
  });
}
