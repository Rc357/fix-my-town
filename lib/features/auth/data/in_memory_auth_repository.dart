import 'dart:async';

import 'package:obserba/features/auth/domain/app_user.dart';
import 'package:obserba/features/auth/domain/auth_exception.dart';
import 'package:obserba/features/auth/domain/auth_repository.dart';

/// A credential-free adapter that keeps this starter runnable.
///
/// Replace the provider with a Firebase, Supabase, or API adapter in a real app.
class InMemoryAuthRepository implements AuthRepository {
  final _controller = StreamController<AppUser?>.broadcast();
  AppUser? _currentUser;

  // Keyed by a fake external id so repeatedly tapping "Continue with
  // Google/Facebook" in the same session simulates the same account
  // returning (and remembering whatever username it set) rather than
  // minting a fresh account — closer to how a real OAuth provider behaves,
  // and needed to actually exercise the sign-in-again-after-completing-
  // the-username-gate path during manual testing.
  final _simulatedOAuthAccounts = <String, AppUser>{};

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
    _currentUser = AppUser(
      id: email.toLowerCase(),
      email: email,
      username: email.split('@').first,
    );
    _controller.add(_currentUser);
  }

  @override
  Future<void> signUp({
    required String email,
    required String password,
    required String username,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    if (!email.contains('@') || password.length < 8) {
      throw const AuthException(
        'Enter a valid email and 8-character password.',
      );
    }
    if (username.trim().isEmpty) {
      throw const AuthException('Choose a username.');
    }
    _currentUser = AppUser(
      id: email.toLowerCase(),
      email: email,
      username: username.trim(),
    );
    _controller.add(_currentUser);
  }

  @override
  Future<void> setUsername(String username) async {
    final user = _currentUser;
    if (user == null) {
      throw const AuthException('Sign in before choosing a username.');
    }
    if (username.trim().isEmpty) {
      throw const AuthException('Username cannot be empty.');
    }
    _currentUser = user.copyWith(username: username.trim());
    _simulatedOAuthAccounts[user.id] = _currentUser!;
    _controller.add(_currentUser);
  }

  @override
  Future<void> setShowRealName(bool value) async {
    final user = _currentUser;
    if (user == null) return;
    _currentUser = user.copyWith(showRealName: value);
    _controller.add(_currentUser);
  }

  @override
  Future<void> setBarangay(String barangayId) async {
    final user = _currentUser;
    if (user == null) return;
    _currentUser = user.copyWith(barangayId: barangayId);
    _simulatedOAuthAccounts[user.id] = _currentUser!;
    _controller.add(_currentUser);
  }

  @override
  Future<void> signInWithGoogle() =>
      _signInWithSimulatedOAuth(provider: 'google', realName: 'Alex Santos');

  @override
  Future<void> signInWithFacebook() => _signInWithSimulatedOAuth(
    provider: 'facebook',
    realName: 'Jamie Cruz',
  );

  Future<void> _signInWithSimulatedOAuth({
    required String provider,
    required String realName,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    const externalId = 'demo-user'; // one simulated identity per provider
    final id = '$provider:$externalId';
    final existing = _simulatedOAuthAccounts[id];
    if (existing != null) {
      _currentUser = existing;
      _controller.add(_currentUser);
      return;
    }
    // First-time sign-in: username null on purpose — this is what triggers
    // the mandatory ChooseUsernameScreen gate (FR-16.3). Real name is
    // captured but never shown until the user opts in (FR-16.2).
    final created = AppUser(id: id, email: '$externalId@$provider.example', realName: realName);
    _simulatedOAuthAccounts[id] = created;
    _currentUser = created;
    _controller.add(_currentUser);
  }

  @override
  Future<void> signOut() async {
    _currentUser = null;
    _controller.add(null);
  }

  void dispose() => _controller.close();
}
