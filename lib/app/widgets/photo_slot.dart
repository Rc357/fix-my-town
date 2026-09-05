import 'dart:io';

import 'package:fixmytown_citizen/app/theme/fmt_colors.dart';
import 'package:fixmytown_citizen/app/theme/fmt_spacing.dart';
import 'package:flutter/material.dart';

/// `.photo-slot` from the mockup. Wraps the actual camera capture flow —
/// see features/incident_reporting for the image_picker call. There is
/// deliberately no gallery option anywhere this is used: see
/// docs-mobile/07-device-capabilities.md "Camera — capture only".
class PhotoSlot extends StatelessWidget {
  const PhotoSlot({
    required this.label,
    required this.onTap,
    this.imageFile,
    this.required = false,
    this.height = 120,
    super.key,
  });

  final String label;
  final VoidCallback onTap;
  final File? imageFile;
  final bool required;
  final double height;

  @override
  Widget build(BuildContext context) {
    final filled = imageFile != null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(FmtRadius.card),
        child: Container(
          height: height,
          width: double.infinity,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: FmtColors.surface,
            borderRadius: BorderRadius.circular(FmtRadius.card),
            border: Border.all(
              color: filled ? FmtColors.brand : FmtColors.line,
            ),
          ),
          child: filled
              ? Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.file(imageFile!, fit: BoxFit.cover),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 4,
                          horizontal: FmtSpace.sm,
                        ),
                        color: Colors.black.withValues(alpha: 0.55),
                        child: Text(
                          label,
                          style: const TextStyle(
                            fontSize: 9.5,
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.camera_alt_outlined,
                      size: 22,
                      color: FmtColors.muted,
                    ),
                    const SizedBox(height: FmtSpace.xs),
                    Text(
                      required ? '$label *required' : label,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: FmtColors.muted,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
