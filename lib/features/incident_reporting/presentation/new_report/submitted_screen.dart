import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:obserba/app/theme/obs_colors.dart';
import 'package:obserba/app/theme/obs_spacing.dart';
import 'package:obserba/app/theme/obs_text_styles.dart';
import 'package:obserba/app/widgets/obs_button.dart';
import 'package:obserba/app/widgets/workflow_timeline.dart';

class SubmittedScreen extends StatelessWidget {
  const SubmittedScreen({required this.trackingId, super.key});

  final String trackingId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(ObsSpace.xl),
          child: Column(
            children: [
              const Spacer(),
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: ObsColors.greenTint,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_rounded,
                  color: ObsColors.green,
                  size: 36,
                ),
              ),
              const SizedBox(height: ObsSpace.lg),
              const Text(
                'Report submitted',
                style: TextStyle(
                  fontSize: ObsFontSize.xxl,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: ObsSpace.sm),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: ObsSpace.md,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: ObsColors.brandTint,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  trackingId,
                  style: TextStyle(
                    fontFeatures: const [FontFeature.tabularFigures()],
                    fontWeight: FontWeight.w700,
                    color: ObsColors.brandInk,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(height: ObsSpace.xl),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'WHAT HAPPENS NEXT',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ),
              const SizedBox(height: ObsSpace.sm),
              WorkflowTimeline(
                steps: const [
                  TimelineStepData(
                    title: 'Duplicate check',
                    subtitle: 'Comparing against nearby open reports',
                    state: TimelineStepState.current,
                  ),
                  TimelineStepData(
                    title: 'Barangay review',
                    state: TimelineStepState.pending,
                  ),
                  TimelineStepData(
                    title: 'Assigned to a department',
                    state: TimelineStepState.pending,
                  ),
                ],
              ),
              const Spacer(),
              PrimaryButton(
                label: 'Track this report',
                onPressed: () => context.go('/reports/$trackingId'),
              ),
              const SizedBox(height: ObsSpace.sm),
              OutlineButton(
                label: 'Report another issue',
                onPressed: () => context.go('/reports/new/category'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
