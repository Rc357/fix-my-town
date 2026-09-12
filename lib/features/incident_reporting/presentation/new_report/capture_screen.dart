import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:obserba/app/theme/obs_colors.dart';
import 'package:obserba/app/theme/obs_spacing.dart';
import 'package:obserba/app/theme/obs_text_styles.dart';
import 'package:obserba/app/widgets/map_preview.dart';
import 'package:obserba/app/widgets/obs_button.dart';
import 'package:obserba/app/widgets/stepper_dots.dart';
import 'package:obserba/features/incident_reporting/presentation/new_report/new_report_controller.dart';

class CaptureScreen extends ConsumerWidget {
  const CaptureScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(newReportControllerProvider);
    final controller = ref.read(newReportControllerProvider.notifier);

    ref.listen(newReportControllerProvider, (previous, next) {
      if (next.error != null && next.error != previous?.error) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(next.error!)));
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Photo/video & location')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(ObsSpace.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const StepperDots(total: 3, currentIndex: 1),
              const SizedBox(height: ObsSpace.lg),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'PHOTOS OR VIDEO *REQUIRED',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      const SizedBox(height: ObsSpace.sm),
                      if (draft.hasVideo)
                        Container(
                          height: 160,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: ObsColors.surface,
                            border: Border.all(color: ObsColors.brand),
                            borderRadius: BorderRadius.circular(ObsRadius.card),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.videocam,
                                size: 28,
                                color: ObsColors.brand,
                              ),
                              const SizedBox(height: ObsSpace.xs),
                              Text(
                                'Video attached (${draft.videoDurationSeconds}s)',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: ObsFontSize.md,
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        SizedBox(
                          height: 96,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: draft.photoPaths.length + 1,
                            separatorBuilder: (context, index) =>
                                const SizedBox(width: ObsSpace.sm),
                            itemBuilder: (context, index) {
                              if (index == draft.photoPaths.length) {
                                return _AddPhotoTile(
                                  enabled: draft.canAddMorePhotos,
                                  onTap: controller.capturePhoto,
                                );
                              }
                              return _PhotoThumbnail(
                                file: File(draft.photoPaths[index]),
                                onRemove: () => controller.removePhotoAt(index),
                              );
                            },
                          ),
                        ),
                      if (!draft.hasVideo)
                        Padding(
                          padding: const EdgeInsets.only(top: ObsSpace.xs),
                          child: Text(
                            draft.hasPhotos
                                ? '${draft.photoPaths.length}/$maxPhotosPerReport photos added'
                                : 'Tap to take a photo',
                            style: TextStyle(
                              fontSize: ObsFontSize.sm,
                              color: ObsColors.muted,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      const SizedBox(height: ObsSpace.sm),
                      OutlineButton(
                        label: draft.isProcessingVideo
                            ? 'Preparing video…'
                            : draft.hasVideo
                            ? 'Record a different video'
                            : 'Record a video instead (up to 3 min)',
                        icon: Icons.videocam_outlined,
                        onPressed: draft.isProcessingVideo
                            ? null
                            : controller.captureVideo,
                      ),
                      const SizedBox(height: ObsSpace.xl),
                      Text(
                        'LOCATION *REQUIRED',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      const SizedBox(height: ObsSpace.sm),
                      if (draft.hasLocation)
                        MapPreview(address: draft.formattedLocation)
                      else
                        Container(
                          height: 120,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            border: Border.all(color: ObsColors.line),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: draft.isLocating
                              ? const CircularProgressIndicator()
                              : TextButton.icon(
                                  onPressed: controller.captureLocation,
                                  icon: const Icon(Icons.my_location),
                                  label: const Text('Use my current location'),
                                ),
                        ),
                      if (draft.hasLocation)
                        Padding(
                          padding: const EdgeInsets.only(top: ObsSpace.sm),
                          child: TextButton.icon(
                            onPressed: controller.captureLocation,
                            icon: const Icon(Icons.refresh, size: 16),
                            label: const Text('Refresh location'),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: ObsSpace.lg),
              PrimaryButton(
                label: 'Next',
                onPressed: draft.hasMedia && draft.hasLocation
                    ? () => context.push('/reports/new/review')
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// One captured photo, with a remove button (FR-1.2's multi-photo strip).
class _PhotoThumbnail extends StatelessWidget {
  const _PhotoThumbnail({required this.file, required this.onRemove});

  final File file;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 96,
      height: 96,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(ObsRadius.card),
            child: Image.file(
              file,
              width: 96,
              height: 96,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, size: 14, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The trailing "capture another photo" tile in the strip — disabled once
/// [maxPhotosPerReport] is reached.
class _AddPhotoTile extends StatelessWidget {
  const _AddPhotoTile({required this.enabled, required this.onTap});

  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(ObsRadius.card),
        child: Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            color: ObsColors.surface,
            borderRadius: BorderRadius.circular(ObsRadius.card),
            border: Border.all(
              color: enabled ? ObsColors.line : ObsColors.muted.withValues(alpha: 0.3),
            ),
          ),
          child: Icon(
            Icons.add_a_photo_outlined,
            color: enabled ? ObsColors.muted : ObsColors.muted.withValues(alpha: 0.4),
          ),
        ),
      ),
    );
  }
}
