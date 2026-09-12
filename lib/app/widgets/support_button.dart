import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:obserba/app/theme/obs_colors.dart';
import 'package:obserba/features/incident_reporting/data/report_providers.dart';
import 'package:obserba/features/incident_reporting/domain/report_reaction.dart';

/// FR-17.1's "support" reaction as a single-tap toggle — the feed-card
/// equivalent of a like button. Displayed as "Bump" (Reddit/Stack Overflow-
/// style vote wording) — a UI label choice only, the underlying
/// ReactionKind.support/DB value stay as "support" so nothing here needs a
/// data migration. Deliberately doesn't handle "dispute" here: that requires
/// a reason (FR-17.3), which doesn't fit a one-tap feed interaction — see
/// report_detail_screen.dart's full reactions row for where dispute
/// ("Debump") actually lives.
class SupportButton extends ConsumerWidget {
  const SupportButton({
    required this.reportId,
    required this.supportCount,
    this.enabled = true,
    super.key,
  });

  final String reportId;
  final int supportCount;
  final bool enabled;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myReactionAsync = ref.watch(myReactionForReportProvider(reportId));
    final isSupporting = myReactionAsync.value == ReactionKind.support;

    Future<void> toggle() async {
      final repository = ref.read(reportRepositoryProvider);
      if (isSupporting) {
        await repository.removeReaction(reportId);
      } else {
        await repository.react(reportId, ReactionKind.support);
      }
      ref.invalidate(myReactionForReportProvider(reportId));
    }

    final color = isSupporting ? ObsColors.brand : ObsColors.muted;
    return TextButton.icon(
      onPressed: enabled ? toggle : null,
      style: TextButton.styleFrom(foregroundColor: color, padding: EdgeInsets.zero),
      icon: Icon(
        isSupporting ? Icons.thumb_up_alt : Icons.thumb_up_alt_outlined,
        size: 18,
        color: color,
      ),
      label: Text(
        supportCount > 0 ? '$supportCount' : 'Bump',
        style: TextStyle(fontWeight: FontWeight.w700, color: color),
      ),
    );
  }
}
