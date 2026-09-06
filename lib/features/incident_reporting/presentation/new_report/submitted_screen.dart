import 'package:fixmytown_citizen/app/theme/fmt_colors.dart';
import 'package:fixmytown_citizen/app/theme/fmt_spacing.dart';
import 'package:fixmytown_citizen/app/theme/fmt_text_styles.dart';
import 'package:fixmytown_citizen/app/widgets/fmt_button.dart';
import 'package:fixmytown_citizen/app/widgets/workflow_timeline.dart';
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
          padding: const EdgeInsets.all(FmtSpace.xl),
          child: Column(
            children: [
              const Spacer(),
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  color: FmtColors.greenTint,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: FmtColors.green,
                  size: 36,
                ),
              ),
              const SizedBox(height: FmtSpace.lg),
              const Text(
                'Report submitted',
                style: TextStyle(
                  fontSize: FmtFontSize.xxl,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: FmtSpace.sm),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: FmtSpace.md,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: FmtColors.brandTint,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  trackingId,
                  style: TextStyle(
                    fontFeatures: const [FontFeature.tabularFigures()],
                    fontWeight: FontWeight.w700,
                    color: FmtColors.brandInk,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(height: FmtSpace.xl),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'WHAT HAPPENS NEXT',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ),
              const SizedBox(height: FmtSpace.sm),
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
              const SizedBox(height: FmtSpace.sm),
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
