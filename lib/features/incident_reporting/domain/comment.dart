/// FR-18.1. `authorUsername` is embedded rather than looked up separately —
/// the public identity (username, never real name — see AppUser's doc
/// comment) is exactly what a comment thread needs to render, and comments
/// are read far more often than a per-comment user lookup would be cheap.
class Comment {
  const Comment({
    required this.id,
    required this.reportId,
    required this.authorUserId,
    required this.authorUsername,
    required this.body,
    required this.createdAt,
    this.isHidden = false,
  });

  final String id;
  final String reportId;
  final String authorUserId;
  final String authorUsername;
  final String body;
  final DateTime createdAt;

  /// FR-18.3 — hidden, not deleted. This app has no Barangay Staff UI (no
  /// staff-facing surface exists in mobile-citizen at all), so nothing here
  /// ever sets this true — it exists so a hidden comment fetched from a real
  /// backend renders correctly (or is filtered out) rather than crashing on
  /// an unrecognized shape.
  final bool isHidden;
}
