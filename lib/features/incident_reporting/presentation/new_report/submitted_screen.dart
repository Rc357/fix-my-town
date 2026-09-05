import 'package:aninag_citizen/app/theme/aninag_colors.dart';
import 'package:aninag_citizen/app/theme/aninag_spacing.dart';
import 'package:aninag_citizen/app/widgets/aninag_button.dart';
import 'package:aninag_citizen/app/widgets/workflow_timeline.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SubmittedScreen extends StatelessWidget {
  const SubmittedScreen({required this.trackingId, super.key});

  final String trackingId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AninagSpace.xl),
          child: Column(
            children: [
              const Spacer(),
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  color: AninagColors.greenTint,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: AninagColors.green,
                  size: 36,
                ),
              ),
              const SizedBox(height: AninagSpace.lg),
              const Text(
                'Report submitted',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: AninagSpace.sm),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AninagSpace.md,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AninagColors.brandTint,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  trackingId,
                  style: const TextStyle(
                    fontFeatures: [FontFeature.tabularFigures()],
                    fontWeight: FontWeight.w700,
                    color: AninagColors.brandInk,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(height: AninagSpace.xl),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'WHAT HAPPENS NEXT',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ),
              const SizedBox(height: AninagSpace.sm),
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
              const SizedBox(height: AninagSpace.sm),
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
