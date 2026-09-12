import 'package:flutter/material.dart';
import 'package:obserba/app/theme/obs_colors.dart';

/// `.stepper-mini` from the mockup — multi-step form progress
/// (category -> capture -> review).
class StepperDots extends StatelessWidget {
  const StepperDots({
    required this.total,
    required this.currentIndex,
    super.key,
  });

  final int total;
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < total; i++) ...[
          Container(
            width: 9,
            height: 9,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: i <= currentIndex ? ObsColors.amber : ObsColors.line,
            ),
          ),
          if (i != total - 1)
            Expanded(child: Container(height: 2, color: ObsColors.line)),
        ],
      ],
    );
  }
}
