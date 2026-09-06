/// A barangay a citizen can pick as their "home" location (see
/// AppUser.barangayId). Deliberately just id/name — no boundary geometry,
/// since barangay_boundary polygon data isn't imported (see
/// CategoryRepository's sibling doc comments for the same "picked manually,
/// not GPS-resolved" reasoning).
class Barangay {
  const Barangay({required this.id, required this.name});

  final String id;
  final String name;
}
