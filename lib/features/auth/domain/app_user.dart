/// `username` is the public identity shown everywhere else in the app
/// (comments, reactions, transparency feed) — see docs/07-database-design.md
/// "username is the public identity, display_name is protected PII".
/// `realName`/`showRealName` exist so an OAuth provider's real name never
/// leaks to other users unless the account holder explicitly opts in
/// (FR-16.2) — anonymous/pseudonymous is the default, not opt-in.
class AppUser {
  const AppUser({
    required this.id,
    required this.email,
    this.username,
    this.realName,
    this.showRealName = false,
    this.barangayId,
  });

  final String id;
  final String email;
  final String? username;
  final String? realName;
  final bool showRealName;

  /// The citizen's self-selected "home" barangay — independent of GPS/
  /// boundary resolution (there's no barangay_boundary polygon data to
  /// resolve against yet). Null until they pick one via the home screen's
  /// barangay picker.
  final String? barangayId;

  /// True for a first-time OAuth sign-in (Google/Facebook/Apple) that hasn't
  /// completed the mandatory username step yet (FR-16.3). Email/password
  /// signup collects the username directly, so this is never true for that
  /// provider — see SignupScreen vs ChooseUsernameScreen.
  bool get needsUsername => username == null || username!.isEmpty;

  /// What other users should actually see — never `realName` unless the
  /// account holder opted in. Falls back to the username even when
  /// `showRealName` is true but no real name was ever supplied.
  String get publicDisplayName {
    if (showRealName && realName != null && realName!.isNotEmpty) {
      return realName!;
    }
    return username ?? 'Citizen';
  }

  AppUser copyWith({
    String? username,
    String? realName,
    bool? showRealName,
    String? barangayId,
  }) => AppUser(
    id: id,
    email: email,
    username: username ?? this.username,
    realName: realName ?? this.realName,
    showRealName: showRealName ?? this.showRealName,
    barangayId: barangayId ?? this.barangayId,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppUser &&
          other.id == id &&
          other.email == email &&
          other.username == username &&
          other.realName == realName &&
          other.showRealName == showRealName &&
          other.barangayId == barangayId;

  @override
  int get hashCode =>
      Object.hash(id, email, username, realName, showRealName, barangayId);
}
