import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:obserba/app/theme/obs_colors.dart';
import 'package:obserba/app/theme/obs_spacing.dart';
import 'package:obserba/app/theme/obs_text_styles.dart';
import 'package:obserba/app/widgets/status_chip.dart';
import 'package:obserba/app/widgets/support_button.dart';
import 'package:obserba/app/widgets/verified_badge.dart';
import 'package:obserba/features/incident_reporting/data/category_providers.dart';
import 'package:obserba/features/incident_reporting/domain/report.dart';
import 'package:obserba/features/incident_reporting/domain/report_category.dart';
import 'package:obserba/features/incident_reporting/presentation/widgets/report_media_carousel.dart';

/// FR-20.1 — a scrollable-feed "post," Facebook-post-style: a header row
/// (round icon "avatar", category name, timestamp, status), full-bleed
/// media, then a divider-separated, evenly-split action row — not the
/// compact ReportCard used by My Reports (kept separate on purpose: that
/// list is a personal utility view, this is the browsable social surface —
/// different jobs, different information density).
///
/// Bordered + rounded, same as `ReportCard`/`CategoryTile` elsewhere — the
/// page background is the same white as the post itself, so without a
/// border the only thing separating two posts in the feed was a thin gap,
/// which read as a stray line rather than a card boundary.
class ReportFeedPost extends ConsumerWidget {
  const ReportFeedPost({required this.report, required this.onTap, super.key});

  final Report report;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final category =
        categoriesAsync.value?.byId(report.categoryId) ??
        unknownCategory(report.categoryId);
    final (chipBg, chipFg) = statusToneColors(report.status.tone);

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: ObsColors.surface,
        border: Border.all(color: ObsColors.line),
        borderRadius: BorderRadius.circular(ObsRadius.card),
      ),
      child: Material(
        color: ObsColors.surface,
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  ObsSpace.md,
                  ObsSpace.md,
                  ObsSpace.md,
                  ObsSpace.sm,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: chipBg,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(category.icon, color: chipFg, size: 20),
                    ),
                    const SizedBox(width: ObsSpace.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  category.label,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (report.isVerified) ...[
                                const SizedBox(width: ObsSpace.xs),
                                const VerifiedBadge(),
                              ],
                            ],
                          ),
                          Text(
                            _relativeTime(report.createdAt),
                            style: TextStyle(
                              fontSize: ObsFontSize.sm,
                              color: ObsColors.muted,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    StatusChip(
                      label: report.status.label,
                      tone: report.status.tone,
                    ),
                  ],
                ),
              ),
              if (report.description.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    ObsSpace.md,
                    0,
                    ObsSpace.md,
                    ObsSpace.sm,
                  ),
                  child: Text(
                    report.description,
                    style: TextStyle(
                      fontSize: ObsFontSize.xl,
                      color: ObsColors.ink,
                    ),
                  ),
                ),
              if (report.media.hasPhotos || report.media.hasVideo)
                ReportMediaCarousel(media: report.media),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: ObsSpace.md),
                child: Divider(height: ObsSpace.md),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  ObsSpace.sm,
                  0,
                  ObsSpace.sm,
                  ObsSpace.xs,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Center(
                        child: SupportButton(
                          reportId: report.id,
                          supportCount: report.supportCount,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: TextButton.icon(
                          onPressed: onTap,
                          style: TextButton.styleFrom(
                            foregroundColor: ObsColors.muted,
                            padding: EdgeInsets.zero,
                          ),
                          icon: const Icon(
                            Icons.mode_comment_outlined,
                            size: 18,
                          ),
                          label: Text(
                            report.commentCount > 0
                                ? '${report.commentCount}'
                                : 'Comment',
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _relativeTime(DateTime createdAt) {
    final minutes = DateTime.now().difference(createdAt).inMinutes;
    return switch (minutes) {
      < 1 => 'Just now',
      < 60 => '${minutes}m ago',
      < 60 * 24 => '${minutes ~/ 60}h ago',
      _ => '${minutes ~/ (60 * 24)}d ago',
    };
  }
}
