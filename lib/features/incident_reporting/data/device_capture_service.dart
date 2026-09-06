import 'dart:io';

import 'package:flutter_compress/flutter_compress.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';

class CapturedLocation {
  const CapturedLocation({required this.latitude, required this.longitude});

  final double latitude;
  final double longitude;

  /// No reverse-geocoding wired up (that's a separate API-key setup, like
  /// the map SDK itself — see docs-mobile/07-device-capabilities.md). Raw
  /// coordinates are honest; a fabricated street address would not be.
  String get formatted =>
      '${latitude.toStringAsFixed(5)}, ${longitude.toStringAsFixed(5)}';
}

/// FR-20.2 — a compressed, ready-to-upload video. `durationSeconds` is read
/// back from the compressed output, not assumed from the recording UI's cap,
/// since that's what the server-side check constraint (FR-20.4's design
/// note in the Supabase setup guide) is also validating against.
class CapturedVideo {
  const CapturedVideo({required this.path, required this.durationSeconds});

  final String path;
  final int durationSeconds;
}

/// Thrown when a captured video fails FR-20's constraints — caught by
/// NewReportController and surfaced as a client-side error (FR-1.6's "reject
/// before any network call" principle, applied to video the same way it
/// already applies to missing photo/GPS).
class VideoCaptureException implements Exception {
  const VideoCaptureException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// FR-20.4's cap, enforced here independent of image_picker's own
/// maxDuration — that's a recording-UI hint, not a guarantee across every
/// platform/picker combination, so this is the actual enforcement point.
const _maxVideoDuration = Duration(minutes: 3);
const _maxVideoBytes = 50 * 1024 * 1024; // FR-20.4 default, 50MB

/// Real camera + GPS capture — capture-only (no gallery), "when in use"
/// location only. See docs-mobile/07-device-capabilities.md for why both
/// are deliberate, not just defaults.
class DeviceCaptureService {
  final _picker = ImagePicker();

  Future<String?> capturePhoto() async {
    final file = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1600,
      imageQuality: 82,
    );
    return file?.path;
  }

  /// FR-20.2/20.3 — records up to 3 minutes, then compresses client-side
  /// before returning (never uploads the uncompressed original — see the
  /// design note in docs/04-functional-requirements.md's FR-20.3 on why
  /// this happens on-device rather than server-side).
  Future<CapturedVideo?> captureVideo() async {
    final file = await _picker.pickVideo(
      source: ImageSource.camera,
      maxDuration: _maxVideoDuration,
    );
    if (file == null) return null;

    final result = await FlutterCompress.instance.compress(
      file.path,
      const VideoCompressConfig.forSocialMedia(),
    );

    if (result.durationMs > _maxVideoDuration.inMilliseconds) {
      // Defensive, not expected in practice — maxDuration above should
      // already prevent this, but a picker/OS combination that ignores it
      // shouldn't silently produce an over-length upload.
      throw const VideoCaptureException('Video must be 3 minutes or shorter.');
    }

    final sizeBytes = await File(result.outputPath).length();
    if (sizeBytes > _maxVideoBytes) {
      throw const VideoCaptureException(
        'Video is too large even after compression — try recording a shorter clip.',
      );
    }

    return CapturedVideo(
      path: result.outputPath,
      durationSeconds: (result.durationMs / 1000).round(),
    );
  }

  Future<CapturedLocation?> captureLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return null;
    }

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );
    return CapturedLocation(
      latitude: position.latitude,
      longitude: position.longitude,
    );
  }
}
