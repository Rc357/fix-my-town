import 'package:flutter/material.dart';
import 'package:obserba/app/theme/obs_colors.dart';
import 'package:obserba/app/theme/obs_text_styles.dart';

enum TimelineStepState { done, current, pending }

class TimelineStepData {
  const TimelineStepData({
    required this.title,
    this.subtitle,
    required this.state,
  });

  final String title;
  final String? subtitle;
  final TimelineStepState state;
}

/// `.timeline` from the mockup. Presentation-only — renders whatever step
/// list it's given; it has no opinion about which steps exist for a given
/// report (that's workflow-engine/config-owned, per
/// docs-mobile/04-design-system.md).
class WorkflowTimeline extends StatelessWidget {
  const WorkflowTimeline({required this.steps, super.key});

  final List<TimelineStepData> steps;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < steps.length; i++)
          _TimelineRow(step: steps[i], isLast: i == steps.length - 1),
      ],
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({required this.step, required this.isLast});

  final TimelineStepData step;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final dotColor = switch (step.state) {
      TimelineStepState.done => ObsColors.green,
      TimelineStepState.current => ObsColors.amber,
      TimelineStepState.pending => ObsColors.line,
    };
    final lineColor = step.state == TimelineStepState.done
        ? ObsColors.green
        : ObsColors.line;
    final titleColor = step.state == TimelineStepState.pending
        ? ObsColors.muted
        : ObsColors.ink;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 3),
                width: 11,
                height: 11,
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                  boxShadow: step.state == TimelineStepState.current
                      ? [
                          BoxShadow(
                            color: ObsColors.amberTint,
                            blurRadius: 0,
                            spreadRadius: 3,
                          ),
                        ]
                      : null,
                ),
              ),
              if (!isLast)
                Expanded(child: Container(width: 2, color: lineColor)),
            ],
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step.title,
                    style: TextStyle(
                      fontSize: ObsFontSize.lg,
                      fontWeight: FontWeight.w800,
                      color: titleColor,
                    ),
                  ),
                  if (step.subtitle != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 1),
                      child: Text(
                        step.subtitle!,
                        style: TextStyle(
                          fontSize: ObsFontSize.sm,
                          color: ObsColors.muted,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
