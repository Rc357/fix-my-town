import 'package:fixmytown_citizen/app/app.dart';
import 'package:fixmytown_citizen/app/config/app_config.dart';
import 'package:fixmytown_citizen/features/auth/data/auth_providers.dart';
import 'package:fixmytown_citizen/features/auth/data/in_memory_auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('sign-in flow reaches the home screen', (tester) async {
    final repository = InMemoryAuthRepository();
    addTearDown(repository.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appConfigProvider.overrideWithValue(
            AppConfig(
              flavor: AppFlavor.development,
              appName: 'Test App',
              apiBaseUrl: Uri.parse('https://example.test'),
              enableVerboseLogs: false,
            ),
          ),
          authRepositoryProvider.overrideWithValue(repository),
        ],
        child: const App(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('FixMyTown'), findsOneWidget);

    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();

    expect(find.text('Welcome back'), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('emailField')),
      'developer@example.com',
    );
    await tester.enterText(
      find.byKey(const Key('passwordField')),
      'password123',
    );
    await tester.tap(find.byKey(const Key('signInButton')));
    await tester.pumpAndSettle();

    expect(find.text('Report an issue'), findsOneWidget);
  });
}
