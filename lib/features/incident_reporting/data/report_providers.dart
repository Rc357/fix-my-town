import 'package:fixmytown_citizen/features/incident_reporting/data/in_memory_report_repository.dart';
import 'package:fixmytown_citizen/features/incident_reporting/domain/report.dart';
import 'package:fixmytown_citizen/features/incident_reporting/domain/report_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final reportRepositoryProvider = Provider<ReportRepository>((ref) {
  final repository = InMemoryReportRepository();
  ref.onDispose(repository.dispose);
  return repository;
});

final nearbyReportsProvider = StreamProvider<List<Report>>(
  (ref) => ref.watch(reportRepositoryProvider).watchNearby(),
);

final myReportsProvider = StreamProvider<List<Report>>(
  (ref) => ref.watch(reportRepositoryProvider).watchMine(),
);

/// Resolves either an internal report id (from My Reports) or a
/// citizen-facing tracking ID (typed into Track by ID, or arriving fresh
/// off the Submitted screen) to the same detail screen.
final reportByAnyIdProvider = FutureProvider.family<Report?, String>((
  ref,
  idOrTrackingId,
) async {
  final repository = ref.watch(reportRepositoryProvider);
  return await repository.findById(idOrTrackingId) ??
      repository.findByTrackingId(idOrTrackingId);
});
