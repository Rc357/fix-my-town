import 'package:fixmytown_citizen/app/theme/fmt_colors.dart';
import 'package:fixmytown_citizen/app/theme/fmt_spacing.dart';
import 'package:flutter/material.dart';

/// The fixed set of semantic tones a status can render as — deliberately
/// closed (not an arbitrary Color) so a screen can't invent an ad hoc status
/// color. Feature code maps its own status enum to one of these tones; see
/// ReportStatus.tone in incident_reporting/domain/report.dart.
enum StatusTone { pending, progress, resolved, alert, action }

/// Shared so ReportCard's icon tint and StatusChip's fill always agree —
/// one status, one color, everywhere it appears on screen.
(Color background, Color foreground) statusToneColors(StatusTone tone) =>
    switch (tone) {
      StatusTone.pending => (FmtColors.blueTint, FmtColors.blue),
      StatusTone.progress => (FmtColors.amberTint, FmtColors.amber),
      StatusTone.resolved => (FmtColors.greenTint, FmtColors.green),
      StatusTone.alert => (FmtColors.redTint, FmtColors.red),
      StatusTone.action => (FmtColors.brand, Colors.white),
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
        horizontal: FmtSpace.sm,
        vertical: FmtSpace.xs,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(FmtRadius.pill),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w800,
          color: fg,
        ),
      ),
    );
  }
}
