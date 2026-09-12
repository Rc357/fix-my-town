import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obserba/app/app.dart';
import 'package:obserba/app/config/app_config.dart';
import 'package:obserba/app/theme/theme_mode_controller.dart';
import 'package:obserba/features/auth/data/auth_providers.dart';
import 'package:obserba/features/auth/data/in_memory_auth_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('sign-in flow reaches the home screen', (tester) async {
    final repository = InMemoryAuthRepository();
    addTearDown(repository.dispose);
    SharedPreferences.setMockInitialValues({});
    final sharedPreferences = await SharedPreferences.getInstance();

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
          sharedPreferencesProvider.overrideWithValue(sharedPreferences),
        ],
        child: const App(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Obserba'), findsOneWidget);

    await tester.tap(find.text('Sign in with email'));
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
