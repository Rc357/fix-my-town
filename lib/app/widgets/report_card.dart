import 'package:fixmytown_citizen/app/theme/fmt_colors.dart';
import 'package:fixmytown_citizen/app/theme/fmt_spacing.dart';
import 'package:fixmytown_citizen/app/widgets/status_chip.dart';
import 'package:flutter/material.dart';

/// `.card` with `.stripe` from the mockup. The severity stripe is required,
/// not optional — status is never encoded by chip color alone.
class ReportCard extends StatelessWidget {
  const ReportCard({
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.stripeColor,
    required this.title,
    required this.meta,
    required this.statusLabel,
    required this.statusTone,
    this.onTap,
    super.key,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final Color stripeColor;
  final String title;
  final String meta;
  final String statusLabel;
  final StatusTone statusTone;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(FmtRadius.card),
        child: Container(
          padding: const EdgeInsets.all(FmtSpace.md),
          decoration: BoxDecoration(
            color: FmtColors.surface,
            borderRadius: BorderRadius.circular(FmtRadius.card),
            border: Border.all(color: FmtColors.line),
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: 4,
                  decoration: BoxDecoration(
                    color: stripeColor,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(width: FmtSpace.md),
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: iconBackground,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: iconColor, size: 18),
                ),
                const SizedBox(width: FmtSpace.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: FmtColors.ink,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: FmtSpace.sm),
                          StatusChip(label: statusLabel, tone: statusTone),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        meta,
                        style: const TextStyle(
                          fontSize: 11,
                          color: FmtColors.muted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
