import 'package:flutter/material.dart';
import 'package:obserba/app/theme/obs_colors.dart';
import 'package:obserba/app/theme/obs_spacing.dart';
import 'package:obserba/app/theme/obs_text_styles.dart';
import 'package:obserba/app/widgets/status_chip.dart';
import 'package:obserba/app/widgets/verified_badge.dart';

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
    this.isVerified = false,
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
  final bool isVerified;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(ObsRadius.card),
        child: Container(
          padding: const EdgeInsets.all(ObsSpace.md),
          decoration: BoxDecoration(
            color: ObsColors.surface,
            borderRadius: BorderRadius.circular(ObsRadius.card),
            border: Border.all(color: ObsColors.line),
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
                const SizedBox(width: ObsSpace.md),
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: iconBackground,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: iconColor, size: 18),
                ),
                const SizedBox(width: ObsSpace.md),
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
                              style: TextStyle(
                                fontSize: ObsFontSize.lg,
                                fontWeight: FontWeight.w800,
                                color: ObsColors.ink,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: ObsSpace.sm),
                          StatusChip(label: statusLabel, tone: statusTone),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        meta,
                        style: TextStyle(
                          fontSize: ObsFontSize.sm,
                          color: ObsColors.muted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (isVerified) ...[
                        const SizedBox(height: 4),
                        const VerifiedBadge(),
                      ],
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
