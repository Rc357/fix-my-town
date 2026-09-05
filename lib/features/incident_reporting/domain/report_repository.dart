import 'package:aninag_citizen/features/incident_reporting/domain/report.dart';

class NewReportDraft {
  const NewReportDraft({
    required this.categoryId,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.photoPath,
  });

  final String categoryId;
  final String description;
  final double latitude;
  final double longitude;
  final String address;
  final String photoPath;
}

/// Vendor-independent contract — mirrors AuthRepository's pattern (see
/// features/auth/domain/auth_repository.dart). The in-memory implementation
/// is a stand-in until the NestJS API (docs/08-api-specification.md) exists;
/// nothing above this interface should need to change when it's swapped in.
abstract interface class ReportRepository {
  Stream<List<Report>> watchNearby();

  Stream<List<Report>> watchMine();

  Future<Report?> findById(String id);

  Future<Report?> findByTrackingId(String trackingId);

  Future<Report> submit(NewReportDraft draft);

  Future<void> confirmResolved(String reportId);

  Future<void> dispute(String reportId);
}
