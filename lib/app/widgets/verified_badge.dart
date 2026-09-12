import 'package:flutter/material.dart';
import 'package:obserba/app/theme/obs_colors.dart';
import 'package:obserba/app/theme/obs_spacing.dart';
import 'package:obserba/app/theme/obs_text_styles.dart';

/// FR-19 — renders from `report.verifiedAt != null` only, never from
/// `ReportStatus` (FR-19.3: verification and workflow progress answer two
/// different questions). Absent entirely when unverified — not a greyed-out
/// variant — so it can never be mistaken for "checked and found unverified."
/// Never shows an AI-only signal (FR-19.2) — there's no "kind" parameter
/// here on purpose; only Barangay Staff verification produces this badge.
class VerifiedBadge extends StatelessWidget {
  const VerifiedBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: ObsSpace.sm,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: ObsColors.greenTint,
        borderRadius: BorderRadius.circular(ObsRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.verified, size: 12, color: ObsColors.green),
          const SizedBox(width: 3),
          Text(
            'Verified',
            style: TextStyle(
              fontSize: ObsFontSize.xs,
              fontWeight: FontWeight.w800,
              color: ObsColors.green,
            ),
          ),
        ],
      ),
    );
  }
}
