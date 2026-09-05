import 'package:fixmytown_citizen/features/incident_reporting/data/device_capture_service.dart';
import 'package:fixmytown_citizen/features/incident_reporting/data/report_providers.dart';
import 'package:fixmytown_citizen/features/incident_reporting/domain/report.dart';
import 'package:fixmytown_citizen/features/incident_reporting/domain/report_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final deviceCaptureServiceProvider = Provider<DeviceCaptureService>(
  (ref) => DeviceCaptureService(),
);

class NewReportDraftState {
  const NewReportDraftState({
    this.categoryId,
    this.photoPath,
    this.latitude,
    this.longitude,
    this.description = '',
    this.isLocating = false,
    this.isSubmitting = false,
    this.error,
  });

  final String? categoryId;
  final String? photoPath;
  final double? latitude;
  final double? longitude;
  final String description;
  final bool isLocating;
  final bool isSubmitting;
  final String? error;

  bool get hasCategory => categoryId != null;
  bool get hasPhoto => photoPath != null;
  bool get hasLocation => latitude != null && longitude != null;
  bool get canReview => hasCategory && hasPhoto && hasLocation;

  String get formattedLocation => hasLocation
      ? '${latitude!.toStringAsFixed(5)}, ${longitude!.toStringAsFixed(5)}'
      : '';

  NewReportDraftState copyWith({
    String? categoryId,
    String? photoPath,
    double? latitude,
    double? longitude,
    String? description,
    bool? isLocating,
    bool? isSubmitting,
    String? error,
  }) => NewReportDraftState(
    categoryId: categoryId ?? this.categoryId,
    photoPath: photoPath ?? this.photoPath,
    latitude: latitude ?? this.latitude,
    longitude: longitude ?? this.longitude,
    description: description ?? this.description,
    isLocating: isLocating ?? this.isLocating,
    isSubmitting: isSubmitting ?? this.isSubmitting,
    error: error,
  );
}

/// Local-only UI state for the 3-step submission flow — nothing here talks
/// to the network until submit(), consistent with
/// docs-mobile/02-app-architecture.md's Notifier-vs-AsyncNotifier split.
class NewReportController extends Notifier<NewReportDraftState> {
  @override
  NewReportDraftState build() => const NewReportDraftState();

  void selectCategory(String categoryId) {
    state = state.copyWith(categoryId: categoryId);
  }

  Future<void> capturePhoto() async {
    final path = await ref.read(deviceCaptureServiceProvider).capturePhoto();
    if (path != null) state = state.copyWith(photoPath: path);
  }

  Future<void> captureLocation() async {
    state = state.copyWith(isLocating: true, error: null);
    final location = await ref
        .read(deviceCaptureServiceProvider)
        .captureLocation();
    if (location == null) {
      state = state.copyWith(
        isLocating: false,
        error:
            "Couldn't get your location — check location permission and try again.",
      );
      return;
    }
    state = state.copyWith(
      isLocating: false,
      latitude: location.latitude,
      longitude: location.longitude,
    );
  }

  void setDescription(String value) {
    state = state.copyWith(description: value);
  }

  Future<Report?> submit() async {
    if (!state.canReview) return null;
    state = state.copyWith(isSubmitting: true, error: null);
    try {
      final report = await ref
          .read(reportRepositoryProvider)
          .submit(
            NewReportDraft(
              categoryId: state.categoryId!,
              description: state.description,
              latitude: state.latitude!,
              longitude: state.longitude!,
              address: state.formattedLocation,
              photoPath: state.photoPath!,
            ),
          );
      state = const NewReportDraftState();
      return report;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        error: 'Submission failed — please try again.',
      );
      return null;
    }
  }
}

final newReportControllerProvider =
    NotifierProvider<NewReportController, NewReportDraftState>(
      NewReportController.new,
    );
