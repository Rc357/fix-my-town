import 'package:aninag_citizen/app/theme/aninag_colors.dart';
import 'package:aninag_citizen/app/theme/aninag_spacing.dart';
import 'package:flutter/material.dart';

/// `.map-box` from the mockup. A lightweight placeholder — grid + pin, no
/// map SDK — so the app runs without a Google Maps API key. Real GPS
/// coordinates are still captured for real via geolocator; only the visual
/// map rendering is a stand-in. Swap for a real map SDK widget once an API
/// key is provisioned (see docs-mobile/07-device-capabilities.md "Maps").
class MapPreview extends StatelessWidget {
  const MapPreview({this.address, this.height = 120, super.key});

  final String? address;
  final double height;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AninagRadius.card),
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Container(color: const Color(0xFFE4EDE9)),
            CustomPaint(painter: _GridPainter()),
            const Center(
              child: Icon(
                Icons.location_pin,
                color: AninagColors.red,
                size: 30,
              ),
            ),
            if (address != null)
              Positioned(
                left: AninagSpace.sm,
                right: AninagSpace.sm,
                bottom: AninagSpace.sm,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AninagSpace.sm,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.place,
                        size: 12,
                        color: AninagColors.brand,
                      ),
                      const SizedBox(width: 5),
                      Flexible(
                        child: Text(
                          address!,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AninagColors.brand.withValues(alpha: 0.08)
      ..strokeWidth = 1;
    const step = 24.0;
    for (var x = 0.0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (var y = 0.0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
