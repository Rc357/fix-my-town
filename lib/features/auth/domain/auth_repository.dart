import 'package:fixmytown_citizen/features/auth/domain/app_user.dart';

abstract interface class AuthRepository {
  AppUser? get currentUser;

  Stream<AppUser?> authStateChanges();

  Future<void> signIn({required String email, required String password});

  /// Email/password signup collects the username directly (FR-16.4) — unlike
  /// OAuth providers, there's no post-auth completion gate for this path.
  Future<void> signUp({
    required String email,
    required String password,
    required String username,
  });

  /// Google/Facebook don't collect a username as part of their own sign-in
  /// flow — the resulting account has `username: null` until this is called
  /// (FR-16.3). ChooseUsernameScreen is the only caller.
  Future<void> setUsername(String username);

  /// FR-16.2 — the anonymity-by-default toggle. Off unless the account
  /// holder explicitly turns it on.
  Future<void> setShowRealName(bool value);

  /// Sets the citizen's self-selected "home" barangay (see AppUser.barangayId's
  /// doc comment on why this is manual, not GPS-resolved).
  Future<void> setBarangay(String barangayId);

  Future<void> signInWithGoogle();

  Future<void> signInWithFacebook();

  Future<void> signOut();
}
