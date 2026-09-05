import 'package:aninag_citizen/app/theme/aninag_colors.dart';
import 'package:flutter/material.dart';

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
              color: i <= currentIndex ? AninagColors.amber : AninagColors.line,
            ),
          ),
          if (i != total - 1)
            Expanded(child: Container(height: 2, color: AninagColors.line)),
        ],
      ],
    );
  }
}
