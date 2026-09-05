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
