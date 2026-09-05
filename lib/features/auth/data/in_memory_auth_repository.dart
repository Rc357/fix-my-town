import 'dart:async';

import 'package:aninag_citizen/features/auth/domain/app_user.dart';
import 'package:aninag_citizen/features/auth/domain/auth_exception.dart';
import 'package:aninag_citizen/features/auth/domain/auth_repository.dart';

/// A credential-free adapter that keeps this starter runnable.
///
/// Replace the provider with a Firebase, Supabase, or API adapter in a real app.
class InMemoryAuthRepository implements AuthRepository {
  final _controller = StreamController<AppUser?>.broadcast();
  AppUser? _currentUser;

  @override
  AppUser? get currentUser => _currentUser;

  @override
  Stream<AppUser?> authStateChanges() async* {
    yield _currentUser;
    yield* _controller.stream;
  }

  @override
  Future<void> signIn({required String email, required String password}) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    if (!email.contains('@') || password.length < 8) {
      throw const AuthException(
        'Enter a valid email and 8-character password.',
      );
    }
    _currentUser = AppUser(id: email.toLowerCase(), email: email);
    _controller.add(_currentUser);
  }

  @override
  Future<void> signOut() async {
    _currentUser = null;
    _controller.add(null);
  }

  void dispose() => _controller.close();
}
