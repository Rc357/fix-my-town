import 'dart:async';
import 'dart:math';

import 'package:fixmytown_citizen/features/incident_reporting/domain/report.dart';
import 'package:fixmytown_citizen/features/incident_reporting/domain/report_reaction.dart';
import 'package:fixmytown_citizen/features/incident_reporting/domain/report_repository.dart';

/// A backend-free adapter — same pattern as InMemoryAuthRepository. Replace
/// with an adapter over docs/08-api-specification.md's /reports endpoints
/// once the NestJS API exists; nothing in presentation/domain should need
/// to change when it's swapped in (see docs-mobile/05-state-and-data-layer.md).
///
/// [currentUserId] is a callback, not a direct AuthRepository dependency —
/// keeps this feature's data layer decoupled from auth's, per the "explicit
/// contract or provider" cross-feature rule (see README's Feature rules).
class InMemoryReportRepository implements ReportRepository {
  InMemoryReportRepository({required String? Function() currentUserId})
    : _currentUserId = currentUserId {
    _reports.addAll(_seed());
    _mineIds.addAll(_reports.map((r) => r.id));
  }

  final String? Function() _currentUserId;
  final _reports = <Report>[];
  final _mineIds = <String>{};
  final _controller = StreamController<void>.broadcast();
  final _random = Random();

  // reportId -> userId -> (kind, reason). Kept separate from _reports so a
  // reaction never needs to touch the report's own identity/content fields —
  // only the aggregate counts baked into the Report returned to callers.
  final _reactions = <String, Map<String, (ReactionKind, String?)>>{};

  @override
  Stream<List<Report>> watchNearby() async* {
    yield _withCounts(_reports);
    yield* _controller.stream.map((_) => _withCounts(_reports));
  }

  @override
  Stream<List<Report>> watchMine() async* {
    List<Report> mine() =>
        _withCounts(_reports.where((r) => _mineIds.contains(r.id)).toList());
    yield mine();
    yield* _controller.stream.map((_) => mine());
  }

  @override
  Future<Report?> findById(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    for (final report in _reports) {
      if (report.id == id) return _withCounts([report]).first;
    }
    return null;
  }

  @override
  Future<Report?> findByTrackingId(String trackingId) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final normalized = trackingId.trim().toUpperCase();
    for (final report in _reports) {
      if (report.trackingId.toUpperCase() == normalized) {
        return _withCounts([report]).first;
      }
    }
    return null;
  }

  @override
  Future<void> react(String reportId, ReactionKind kind, {String? reason}) async {
    final userId = _currentUserId();
    if (userId == null) {
      throw StateError('Sign in before reacting to a report.');
    }
    if (kind == ReactionKind.dispute && (reason == null || reason.trim().isEmpty)) {
      throw ArgumentError('A reason is required to dispute a report.');
    }
    await Future<void>.delayed(const Duration(milliseconds: 150));
    (_reactions[reportId] ??= {})[userId] = (kind, reason);
    _controller.add(null);
  }

  @override
  Future<void> removeReaction(String reportId) async {
    final userId = _currentUserId();
    if (userId == null) return;
    _reactions[reportId]?.remove(userId);
    _controller.add(null);
  }

  @override
  Future<ReactionKind?> myReaction(String reportId) async {
    final userId = _currentUserId();
    if (userId == null) return null;
    return _reactions[reportId]?[userId]?.$1;
  }

  @override
  Future<String> resolveMediaUrl(String path) async => path;

  // commentCount stays at its Report(...) default (0) here — comments live
  // in the separate InMemoryCommentRepository, which this class has no
  // reference to. Not worth wiring two independent demo stores together
  // just for a count only the no-backend demo path would ever show wrong.
  List<Report> _withCounts(List<Report> reports) => [
    for (final report in reports)
      report.copyWith(
        supportCount: _countReactions(report.id, ReactionKind.support),
        disputeCount: _countReactions(report.id, ReactionKind.dispute),
      ),
  ];

  int _countReactions(String reportId, ReactionKind kind) =>
      _reactions[reportId]?.values.where((r) => r.$1 == kind).length ?? 0;

  @override
  Future<Report> submit(NewReportDraft draft) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    final id = 'r-${_random.nextInt(1 << 32)}';
    final report = Report(
      id: id,
      trackingId: _generateTrackingId(),
      categoryId: draft.categoryId,
      description: draft.description,
      latitude: draft.latitude,
      longitude: draft.longitude,
      address: draft.address,
      status: ReportStatus.submitted,
      createdAt: DateTime.now(),
      media: ReportMedia(
        citizenPhotoPaths: draft.photoPaths,
        citizenVideoPath: draft.videoPath,
        citizenVideoDurationSeconds: draft.videoDurationSeconds,
      ),
    );
    _reports.insert(0, report);
    _mineIds.add(id);
    _controller.add(null);
    return report;
  }

  @override
  Future<void> confirmResolved(String reportId) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    _updateStatus(reportId, ReportStatus.closed);
  }

  @override
  Future<void> dispute(String reportId) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    _updateStatus(reportId, ReportStatus.reopened);
  }

  void _updateStatus(String id, ReportStatus status) {
    final index = _reports.indexWhere((r) => r.id == id);
    if (index == -1) return;
    _reports[index] = _reports[index].copyWith(status: status);
    _controller.add(null);
  }

  String _generateTrackingId() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final code = List.generate(
      6,
      (_) => chars[_random.nextInt(chars.length)],
    ).join();
    return 'FMT-$code';
  }

  void dispose() => _controller.close();

  List<Report> _seed() => [
    Report(
      id: 'seed-1',
      trackingId: 'FMT-8F21QZ',
      categoryId: 'street_light',
      description:
          'Streetlight has been out for a week near the covered court.',
      latitude: 14.6300,
      longitude: 121.0900,
      address: 'Purok 3, Brgy. San Isidro',
      status: ReportStatus.awaitingConfirmation,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      // Demo variety for the Verified badge (FR-19.1) — the other two seeds
      // are left unverified.
      verifiedAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    Report(
      id: 'seed-2',
      trackingId: 'FMT-2WK9F3',
      categoryId: 'flooding',
      description:
          "Knee-deep floodwater blocking the street since this morning's rain.",
      latitude: 14.6255,
      longitude: 121.0930,
      address: 'Riverside St. cor. Rizal Ave.',
      status: ReportStatus.inProgress,
      createdAt: DateTime.now().subtract(const Duration(hours: 6)),
      verifiedAt: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    Report(
      id: 'seed-3',
      trackingId: 'FMT-5T88LX',
      categoryId: 'garbage',
      description: 'Uncollected garbage piling up near the market entrance.',
      latitude: 14.6280,
      longitude: 121.0885,
      address: 'Market Rd.',
      status: ReportStatus.closed,
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
  ];
}
