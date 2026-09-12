import 'dart:async';

import 'package:obserba/features/auth/domain/app_user.dart';
import 'package:obserba/features/auth/domain/auth_exception.dart';
import 'package:obserba/features/auth/domain/auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

/// Deep-link scheme OAuth providers redirect back to after the browser
/// step — must match the native registration (AndroidManifest intent-filter,
/// iOS CFBundleURLTypes) exactly, or the redirect never reaches the app.
const _oauthRedirectUrl = 'io.obserba://login-callback';

/// Backed by Supabase Auth + the `user_account` table (see
/// .test_folder/supabase-setup-guide.md). `AppUser` carries more than the
/// auth session alone has (username, real name, anonymity setting), so this
/// repository maintains a cache populated from `user_account`, refreshed on
/// every auth event and every profile write — `currentUser` stays a
/// synchronous getter (the interface requires it; the router's redirect
/// logic reads it synchronously) while the actual profile fetch is async.
///
/// Aliasing the package import: supabase_flutter exports its own
/// `AuthException`, distinct from this feature's domain `AuthException`.
class SupabaseAuthRepository implements AuthRepository {
  SupabaseAuthRepository(this._client) {
    _client.auth.onAuthStateChange.listen((_) => _refreshCache());
  }

  final supabase.SupabaseClient _client;
  final _controller = StreamController<AppUser?>.broadcast();
  AppUser? _cachedUser;

  @override
  AppUser? get currentUser => _cachedUser;

  @override
  Stream<AppUser?> authStateChanges() async* {
    yield _cachedUser;
    yield* _controller.stream;
  }

  @override
  Future<void> signIn({required String email, required String password}) async {
    try {
      await _client.auth.signInWithPassword(email: email, password: password);
    } on supabase.AuthException catch (error) {
      if (error.code == 'email_not_confirmed') {
        throw EmailConfirmationRequiredException(email);
      }
      throw AuthException(error.message);
    }
  }

  @override
  Future<void> signUp({
    required String email,
    required String password,
    required String username,
  }) async {
    try {
      // `data` lands in auth.users.raw_user_meta_data — the user_account
      // creation trigger reads it to set username at row-creation time, so
      // email/password signup never hits the OAuth username-completion gate.
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {'username': username},
      );
      // `session` is null when Supabase's "Confirm email" setting is on —
      // the account is created (the on_auth_user_created trigger already
      // ran), but there's no active session until the citizen clicks the
      // confirmation link. Surfaced distinctly so the UI shows a "check
      // your inbox" state instead of silently doing nothing (the router's
      // redirect only fires once currentUser is non-null).
      if (response.session == null) {
        throw EmailConfirmationRequiredException(email);
      }
    } on supabase.AuthException catch (error) {
      throw AuthException(error.message);
    }
  }

  @override
  Future<void> setUsername(String username) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw const AuthException('Sign in before choosing a username.');
    }
    try {
      await _client
          .from('user_account')
          .update({'username': username})
          .eq('id', userId);
    } on supabase.PostgrestException catch (error) {
      throw AuthException(error.message);
    }
    // A profile-table write doesn't fire onAuthStateChange — refresh the
    // cache explicitly so the router's redirect gate re-evaluates without
    // waiting for an unrelated auth event.
    await _refreshCache();
  }

  @override
  Future<void> setShowRealName(bool value) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;
    try {
      await _client
          .from('user_account')
          .update({'show_real_name': value})
          .eq('id', userId);
    } on supabase.PostgrestException catch (error) {
      throw AuthException(error.message);
    }
    await _refreshCache();
  }

  @override
  Future<void> setBarangay(String barangayId) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;
    try {
      await _client
          .from('user_account')
          .update({'barangay_id': barangayId})
          .eq('id', userId);
    } on supabase.PostgrestException catch (error) {
      throw AuthException(error.message);
    }
    await _refreshCache();
  }

  @override
  Future<void> signInWithGoogle() => _signInWithOAuth(supabase.OAuthProvider.google);

  @override
  Future<void> signInWithFacebook() =>
      _signInWithOAuth(supabase.OAuthProvider.facebook);

  Future<void> _signInWithOAuth(supabase.OAuthProvider provider) async {
    try {
      // Returns whether the browser launch succeeded, not the auth result —
      // completion happens later via the deep-link redirect firing
      // onAuthStateChange, which the constructor already listens for.
      await _client.auth.signInWithOAuth(provider, redirectTo: _oauthRedirectUrl);
    } on supabase.AuthException catch (error) {
      throw AuthException(error.message);
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } on supabase.AuthException catch (error) {
      throw AuthException(error.message);
    }
  }

  Future<void> _refreshCache() async {
    final authUser = _client.auth.currentUser;
    if (authUser == null) {
      _cachedUser = null;
      _controller.add(null);
      return;
    }
    final profile = await _client
        .from('user_account')
        .select('username, display_name, show_real_name, barangay_id')
        .eq('id', authUser.id)
        .maybeSingle();
    _cachedUser = AppUser(
      id: authUser.id,
      email: authUser.email ?? '',
      username: profile?['username'] as String?,
      realName: profile?['display_name'] as String?,
      showRealName: (profile?['show_real_name'] as bool?) ?? false,
      barangayId: profile?['barangay_id'] as String?,
    );
    _controller.add(_cachedUser);
  }
}
