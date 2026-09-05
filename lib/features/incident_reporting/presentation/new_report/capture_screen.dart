import 'dart:io';

import 'package:fixmytown_citizen/app/theme/fmt_colors.dart';
import 'package:fixmytown_citizen/app/theme/fmt_spacing.dart';
import 'package:fixmytown_citizen/app/widgets/fmt_button.dart';
import 'package:fixmytown_citizen/app/widgets/map_preview.dart';
import 'package:fixmytown_citizen/app/widgets/photo_slot.dart';
import 'package:fixmytown_citizen/app/widgets/stepper_dots.dart';
import 'package:fixmytown_citizen/features/incident_reporting/presentation/new_report/new_report_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
      appBar: AppBar(title: const Text('Photo & location')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(FmtSpace.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const StepperDots(total: 3, currentIndex: 1),
              const SizedBox(height: FmtSpace.lg),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'PHOTO *REQUIRED',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      const SizedBox(height: FmtSpace.sm),
                      PhotoSlot(
                        label: draft.hasPhoto
                            ? 'Photo attached'
                            : 'Tap to take a photo',
                        required: true,
                        height: 160,
                        imageFile: draft.photoPath != null
                            ? File(draft.photoPath!)
                            : null,
                        onTap: controller.capturePhoto,
                      ),
                      const SizedBox(height: FmtSpace.xl),
                      Text(
                        'LOCATION *REQUIRED',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      const SizedBox(height: FmtSpace.sm),
                      if (draft.hasLocation)
                        MapPreview(address: draft.formattedLocation)
                      else
                        Container(
                          height: 120,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            border: Border.all(color: FmtColors.line),
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
                          padding: const EdgeInsets.only(top: FmtSpace.sm),
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
              const SizedBox(height: FmtSpace.lg),
              PrimaryButton(
                label: 'Next',
                onPressed: draft.hasPhoto && draft.hasLocation
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
