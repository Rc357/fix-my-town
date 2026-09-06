import 'package:fixmytown_citizen/app/config/app_config.dart';
import 'package:fixmytown_citizen/features/auth/data/auth_providers.dart';
import 'package:fixmytown_citizen/features/incident_reporting/data/in_memory_report_repository.dart';
import 'package:fixmytown_citizen/features/incident_reporting/data/supabase_report_repository.dart';
import 'package:fixmytown_citizen/features/incident_reporting/domain/report.dart';
import 'package:fixmytown_citizen/features/incident_reporting/domain/report_reaction.dart';
import 'package:fixmytown_citizen/features/incident_reporting/domain/report_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Same fallback pattern as authRepositoryProvider: real Supabase once
/// configured, in-memory demo data otherwise.
final reportRepositoryProvider = Provider<ReportRepository>((ref) {
  final config = ref.watch(appConfigProvider);
  if (config.hasSupabase) {
    return SupabaseReportRepository(Supabase.instance.client);
  }
  final repository = InMemoryReportRepository(
    currentUserId: () => ref.read(authRepositoryProvider).currentUser?.id,
  );
  ref.onDispose(repository.dispose);
  return repository;
});

/// The signed-in viewer's own reaction on a report — deliberately not part
/// of the Report stream, see Report.supportCount's doc comment. `.family`
/// keyed by reportId so the detail screen can watch just this report's.
final myReactionForReportProvider = FutureProvider.family<ReactionKind?, String>(
  (ref, reportId) => ref.watch(reportRepositoryProvider).myReaction(reportId),
);

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
