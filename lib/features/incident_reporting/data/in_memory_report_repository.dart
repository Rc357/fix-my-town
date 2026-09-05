import 'dart:async';
import 'dart:math';

import 'package:aninag_citizen/features/incident_reporting/domain/report.dart';
import 'package:aninag_citizen/features/incident_reporting/domain/report_repository.dart';

/// A backend-free adapter — same pattern as InMemoryAuthRepository. Replace
/// with an adapter over docs/08-api-specification.md's /reports endpoints
/// once the NestJS API exists; nothing in presentation/domain should need
/// to change when it's swapped in (see docs-mobile/05-state-and-data-layer.md).
class InMemoryReportRepository implements ReportRepository {
  InMemoryReportRepository() {
    _reports.addAll(_seed());
    _mineIds.addAll(_reports.map((r) => r.id));
  }

  final _reports = <Report>[];
  final _mineIds = <String>{};
  final _controller = StreamController<void>.broadcast();
  final _random = Random();

  @override
  Stream<List<Report>> watchNearby() async* {
    yield List.unmodifiable(_reports);
    yield* _controller.stream.map((_) => List.unmodifiable(_reports));
  }

  @override
  Stream<List<Report>> watchMine() async* {
    List<Report> mine() =>
        _reports.where((r) => _mineIds.contains(r.id)).toList();
    yield mine();
    yield* _controller.stream.map((_) => mine());
  }

  @override
  Future<Report?> findById(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    for (final report in _reports) {
      if (report.id == id) return report;
    }
    return null;
  }

  @override
  Future<Report?> findByTrackingId(String trackingId) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final normalized = trackingId.trim().toUpperCase();
    for (final report in _reports) {
      if (report.trackingId.toUpperCase() == normalized) return report;
    }
    return null;
  }

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
      photos: ReportPhotos(citizenPhotoPath: draft.photoPath),
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
    return 'ANG-$code';
  }

  void dispose() => _controller.close();

  List<Report> _seed() => [
    Report(
      id: 'seed-1',
      trackingId: 'ANG-8F21QZ',
      categoryId: 'street_light',
      description:
          'Streetlight has been out for a week near the covered court.',
      latitude: 14.6300,
      longitude: 121.0900,
      address: 'Purok 3, Brgy. San Isidro',
      status: ReportStatus.awaitingConfirmation,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    Report(
      id: 'seed-2',
      trackingId: 'ANG-2WK9F3',
      categoryId: 'flooding',
      description:
          "Knee-deep floodwater blocking the street since this morning's rain.",
      latitude: 14.6255,
      longitude: 121.0930,
      address: 'Riverside St. cor. Rizal Ave.',
      status: ReportStatus.inProgress,
      createdAt: DateTime.now().subtract(const Duration(hours: 6)),
    ),
    Report(
      id: 'seed-3',
      trackingId: 'ANG-5T88LX',
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
