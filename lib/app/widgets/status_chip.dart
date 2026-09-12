import 'package:flutter/material.dart';
import 'package:obserba/app/theme/obs_colors.dart';
import 'package:obserba/app/theme/obs_spacing.dart';
import 'package:obserba/app/theme/obs_text_styles.dart';

/// The fixed set of semantic tones a status can render as — deliberately
/// closed (not an arbitrary Color) so a screen can't invent an ad hoc status
/// color. Feature code maps its own status enum to one of these tones; see
/// ReportStatus.tone in incident_reporting/domain/report.dart.
enum StatusTone { pending, progress, resolved, alert, action }

/// Shared so ReportCard's icon tint and StatusChip's fill always agree —
/// one status, one color, everywhere it appears on screen.
(Color background, Color foreground) statusToneColors(StatusTone tone) =>
    switch (tone) {
      StatusTone.pending => (ObsColors.blueTint, ObsColors.blue),
      StatusTone.progress => (ObsColors.amberTint, ObsColors.amber),
      StatusTone.resolved => (ObsColors.greenTint, ObsColors.green),
      StatusTone.alert => (ObsColors.redTint, ObsColors.red),
      StatusTone.action => (ObsColors.brand, Colors.white),
    };

class StatusChip extends StatelessWidget {
  const StatusChip({required this.label, required this.tone, super.key});

  final String label;
  final StatusTone tone;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = statusToneColors(tone);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: ObsSpace.sm,
        vertical: ObsSpace.xs,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(ObsRadius.pill),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: ObsFontSize.xs,
          fontWeight: FontWeight.w800,
          color: fg,
        ),
      ),
    );
  }
}
