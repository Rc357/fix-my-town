import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:obserba/features/auth/data/auth_providers.dart';
import 'package:obserba/features/incident_reporting/data/device_capture_service.dart';
import 'package:obserba/features/incident_reporting/data/report_providers.dart';
import 'package:obserba/features/incident_reporting/domain/report.dart';
import 'package:obserba/features/incident_reporting/domain/report_repository.dart';

final deviceCaptureServiceProvider = Provider<DeviceCaptureService>(
  (ref) => DeviceCaptureService(),
);

/// FR-1.2 — a report can carry several photos (like a multi-photo social
/// post), but not unlimited: caps the capture UI's "add another" affordance
/// and the eventual upload/storage cost per report.
const maxPhotosPerReport = 5;

class NewReportDraftState {
  const NewReportDraftState({
    this.categoryId,
    this.photoPaths = const [],
    this.videoPath,
    this.videoDurationSeconds,
    this.latitude,
    this.longitude,
    this.description = '',
    this.isLocating = false,
    this.isProcessingVideo = false,
    this.isSubmitting = false,
    this.error,
  });

  final String? categoryId;
  final List<String> photoPaths;

  /// FR-20.2 — set only when photoPaths is empty, and vice versa;
  /// addPhoto/withVideo below are what actually enforce that mutual
  /// exclusion.
  final String? videoPath;
  final int? videoDurationSeconds;
  final double? latitude;
  final double? longitude;
  final String description;
  final bool isLocating;

  /// True while flutter_compress is re-encoding a just-recorded video
  /// (FR-20.3) — the capture screen shows a "preparing video…" state during
  /// this, not just a bare loading spinner, since it can take several
  /// seconds and looking stuck would be worse than looking busy.
  final bool isProcessingVideo;
  final bool isSubmitting;
  final String? error;

  bool get hasCategory => categoryId != null;
  bool get hasPhotos => photoPaths.isNotEmpty;
  bool get hasVideo => videoPath != null;
  bool get hasMedia => hasPhotos || hasVideo;
  bool get canAddMorePhotos => photoPaths.length < maxPhotosPerReport;
  bool get hasLocation => latitude != null && longitude != null;
  bool get canReview => hasCategory && hasMedia && hasLocation;

  String get formattedLocation => hasLocation
      ? '${latitude!.toStringAsFixed(5)}, ${longitude!.toStringAsFixed(5)}'
      : '';

  NewReportDraftState copyWith({
    String? categoryId,
    List<String>? photoPaths,
    String? videoPath,
    int? videoDurationSeconds,
    double? latitude,
    double? longitude,
    String? description,
    bool? isLocating,
    bool? isProcessingVideo,
    bool? isSubmitting,
    String? error,
  }) => NewReportDraftState(
    categoryId: categoryId ?? this.categoryId,
    photoPaths: photoPaths ?? this.photoPaths,
    videoPath: videoPath ?? this.videoPath,
    videoDurationSeconds: videoDurationSeconds ?? this.videoDurationSeconds,
    latitude: latitude ?? this.latitude,
    longitude: longitude ?? this.longitude,
    description: description ?? this.description,
    isLocating: isLocating ?? this.isLocating,
    isProcessingVideo: isProcessingVideo ?? this.isProcessingVideo,
    isSubmitting: isSubmitting ?? this.isSubmitting,
    error: error,
  );

  /// Appends a photo and clears any video — capturePhoto/captureVideo call
  /// this and withVideo directly rather than copyWith, since copyWith's
  /// "null means keep existing" convention can't express "replace video
  /// with photo."
  NewReportDraftState addPhoto(String path) => NewReportDraftState(
    categoryId: categoryId,
    photoPaths: [...photoPaths, path],
    videoPath: null,
    videoDurationSeconds: null,
    latitude: latitude,
    longitude: longitude,
    description: description,
    isLocating: isLocating,
    isSubmitting: isSubmitting,
  );

  NewReportDraftState withoutPhotoAt(int index) => NewReportDraftState(
    categoryId: categoryId,
    photoPaths: [...photoPaths]..removeAt(index),
    videoPath: videoPath,
    videoDurationSeconds: videoDurationSeconds,
    latitude: latitude,
    longitude: longitude,
    description: description,
    isLocating: isLocating,
    isSubmitting: isSubmitting,
  );

  NewReportDraftState withVideo(String path, int durationSeconds) => NewReportDraftState(
    categoryId: categoryId,
    photoPaths: const [],
    videoPath: path,
    videoDurationSeconds: durationSeconds,
    latitude: latitude,
    longitude: longitude,
    description: description,
    isLocating: isLocating,
    isSubmitting: isSubmitting,
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
    if (!state.canAddMorePhotos) return;
    final path = await ref.read(deviceCaptureServiceProvider).capturePhoto();
    if (path != null) state = state.addPhoto(path);
  }

  void removePhotoAt(int index) {
    state = state.withoutPhotoAt(index);
  }

  Future<void> captureVideo() async {
    state = state.copyWith(isProcessingVideo: true, error: null);
    try {
      final video = await ref.read(deviceCaptureServiceProvider).captureVideo();
      state = state.copyWith(isProcessingVideo: false);
      if (video != null) {
        state = state.withVideo(video.path, video.durationSeconds);
      }
    } on VideoCaptureException catch (e) {
      state = state.copyWith(isProcessingVideo: false, error: e.message);
    }
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
              photoPaths: state.photoPaths,
              videoPath: state.videoPath,
              videoDurationSeconds: state.videoDurationSeconds,
              barangayId: ref.read(authRepositoryProvider).currentUser?.barangayId,
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
