class AuthException implements Exception {
  const AuthException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Thrown instead of a plain AuthException when Supabase's "Confirm email"
/// setting is on and the account genuinely needs a confirmation-link click
/// before it has a session — not a failure, just a distinct state the UI
/// should show differently (a "check your inbox" dialog, not a red error).
class EmailConfirmationRequiredException extends AuthException {
  const EmailConfirmationRequiredException(this.email)
    : super('Confirm your email before signing in.');

  final String email;
}
