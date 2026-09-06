import 'package:fixmytown_citizen/app/theme/fmt_colors.dart';
import 'package:fixmytown_citizen/app/theme/fmt_spacing.dart';
import 'package:fixmytown_citizen/app/theme/fmt_text_styles.dart';
import 'package:fixmytown_citizen/app/widgets/fmt_button.dart';
import 'package:fixmytown_citizen/app/widgets/verified_badge.dart';
import 'package:fixmytown_citizen/app/widgets/workflow_timeline.dart';
import 'package:fixmytown_citizen/features/auth/data/auth_providers.dart';
import 'package:fixmytown_citizen/features/incident_reporting/data/category_providers.dart';
import 'package:fixmytown_citizen/features/incident_reporting/data/comment_providers.dart';
import 'package:fixmytown_citizen/features/incident_reporting/data/report_providers.dart';
import 'package:fixmytown_citizen/features/incident_reporting/domain/comment.dart';
import 'package:fixmytown_citizen/features/incident_reporting/domain/report.dart';
import 'package:fixmytown_citizen/features/incident_reporting/domain/report_category.dart';
import 'package:fixmytown_citizen/features/incident_reporting/domain/report_reaction.dart';
import 'package:fixmytown_citizen/features/incident_reporting/presentation/widgets/report_media_carousel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ReportDetailScreen extends ConsumerWidget {
  const ReportDetailScreen({required this.idOrTrackingId, super.key});

  final String idOrTrackingId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportAsync = ref.watch(reportByAnyIdProvider(idOrTrackingId));

    return Scaffold(
      appBar: AppBar(title: const Text('Report detail')),
      body: SafeArea(
        child: reportAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) =>
              Center(child: Text('Something went wrong: $error')),
          data: (report) {
            if (report == null) {
              return Padding(
                padding: const EdgeInsets.all(FmtSpace.xl),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.search_off, size: 48, color: FmtColors.muted),
                    SizedBox(height: FmtSpace.md),
                    Text(
                      "We couldn't find a report with that tracking ID.",
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }
            return _ReportDetailBody(report: report);
          },
        ),
      ),
    );
  }
}

class _ReportDetailBody extends ConsumerWidget {
  const _ReportDetailBody({required this.report});

  final Report report;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final category =
        categoriesAsync.value?.byId(report.categoryId) ??
        unknownCategory(report.categoryId);

    return Padding(
      padding: const EdgeInsets.all(FmtSpace.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: FmtColors.brandTint,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(category.icon, color: FmtColors.brandInk),
              ),
              const SizedBox(width: FmtSpace.md),
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
                              fontWeight: FontWeight.w800,
                              fontSize: FmtFontSize.xxl,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (report.isVerified) ...[
                          const SizedBox(width: FmtSpace.xs),
                          const VerifiedBadge(),
                        ],
                      ],
                    ),
                    Text(
                      report.trackingId,
                      style: const TextStyle(
                        fontSize: FmtFontSize.sm,
                        color: FmtColors.muted,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: FmtSpace.lg),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (report.media.hasPhotos || report.media.hasVideo) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(FmtRadius.card),
                      child: ReportMediaCarousel(media: report.media, height: 260),
                    ),
                    const SizedBox(height: FmtSpace.lg),
                  ],
                  WorkflowTimeline(steps: buildReportTimeline(report.status)),
                  if (report.description.isNotEmpty) ...[
                    Text(
                      'CITIZEN NOTE',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    const SizedBox(height: FmtSpace.xs),
                    Text(
                      report.description,
                      style: const TextStyle(
                        fontSize: FmtFontSize.xl,
                        color: FmtColors.ink,
                      ),
                    ),
                    const SizedBox(height: FmtSpace.lg),
                  ],
                  Text(
                    'LOCATION',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(height: FmtSpace.xs),
                  Text(report.address, style: const TextStyle(fontSize: FmtFontSize.lg)),
                  const SizedBox(height: FmtSpace.lg),
                  _ReactionsRow(report: report),
                  const SizedBox(height: FmtSpace.lg),
                  const Divider(),
                  const SizedBox(height: FmtSpace.sm),
                  _CommentsSection(reportId: report.id),
                ],
              ),
            ),
          ),
          if (report.status.needsCitizenConfirmation) ...[
            const SizedBox(height: FmtSpace.md),
            Row(
              children: [
                Expanded(
                  child: OutlineButton(
                    label: 'Not resolved',
                    onPressed: () =>
                        ref.read(reportRepositoryProvider).dispute(report.id),
                  ),
                ),
                const SizedBox(width: FmtSpace.sm),
                Expanded(
                  child: PrimaryButton(
                    label: 'Confirm resolved',
                    onPressed: () => ref
                        .read(reportRepositoryProvider)
                        .confirmResolved(report.id),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// FR-17 — support/dispute. Requires being signed in; a Guest sees the
/// counts (FR-17.2) but the buttons are disabled with an explanatory label
/// rather than hidden, so the feature is discoverable.
class _ReactionsRow extends ConsumerWidget {
  const _ReactionsRow({required this.report});

  final Report report;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSignedIn = ref.watch(authRepositoryProvider).currentUser != null;
    final myReactionAsync = ref.watch(myReactionForReportProvider(report.id));
    final myReaction = myReactionAsync.value;

    Future<void> react(ReactionKind kind) async {
      if (kind == ReactionKind.dispute) {
        final reason = await _promptDisputeReason(context);
        if (reason == null) return; // cancelled
        await ref
            .read(reportRepositoryProvider)
            .react(report.id, kind, reason: reason);
      } else {
        await ref.read(reportRepositoryProvider).react(report.id, kind);
      }
      ref.invalidate(myReactionForReportProvider(report.id));
    }

    return Row(
      children: [
        Expanded(
          child: _ReactionButton(
            icon: Icons.thumb_up_alt_outlined,
            label: 'Support',
            count: report.supportCount,
            active: myReaction == ReactionKind.support,
            onPressed: isSignedIn ? () => react(ReactionKind.support) : null,
          ),
        ),
        const SizedBox(width: FmtSpace.sm),
        Expanded(
          child: _ReactionButton(
            icon: Icons.flag_outlined,
            label: 'Dispute',
            count: report.disputeCount,
            active: myReaction == ReactionKind.dispute,
            onPressed: isSignedIn ? () => react(ReactionKind.dispute) : null,
          ),
        ),
      ],
    );
  }

  Future<String?> _promptDisputeReason(BuildContext context) {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Why do you dispute this report?'),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLines: 3,
          decoration: const InputDecoration(hintText: 'A brief reason is required.'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (controller.text.trim().isEmpty) return;
              Navigator.of(context).pop(controller.text.trim());
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}

class _ReactionButton extends StatelessWidget {
  const _ReactionButton({
    required this.icon,
    required this.label,
    required this.count,
    required this.active,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final int count;
  final bool active;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final color = active ? FmtColors.brand : FmtColors.muted;
    return OutlinedButton.icon(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: active ? FmtColors.brand : FmtColors.line),
      ),
      icon: Icon(icon, size: 16, color: color),
      label: Text(count > 0 ? '$label ($count)' : label),
    );
  }
}

/// FR-18. Guests see the thread (FR-18.1's visibility applies to anyone) but
/// can't post — same disabled-with-explanation pattern as reactions above.
class _CommentsSection extends ConsumerWidget {
  const _CommentsSection({required this.reportId});

  final String reportId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final commentsAsync = ref.watch(commentsForReportProvider(reportId));
    final user = ref.watch(authRepositoryProvider).currentUser;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('COMMENTS', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: FmtSpace.sm),
        commentsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Text('Couldn\'t load comments: $error'),
          data: (comments) => comments.isEmpty
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: FmtSpace.sm),
                  child: Text(
                    'No comments yet.',
                    style: TextStyle(color: FmtColors.muted),
                  ),
                )
              : Column(
                  children: [
                    for (final comment in comments)
                      _CommentTile(comment: comment),
                  ],
                ),
        ),
        const SizedBox(height: FmtSpace.sm),
        if (user?.username != null)
          _CommentComposer(reportId: reportId)
        else
          const Text(
            'Sign in with a username to comment.',
            style: TextStyle(color: FmtColors.muted, fontSize: FmtFontSize.md),
          ),
      ],
    );
  }
}

class _CommentTile extends ConsumerWidget {
  const _CommentTile({required this.comment});

  final Comment comment;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: FmtSpace.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  comment.authorUsername,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: FmtFontSize.md,
                  ),
                ),
                Text(comment.body, style: const TextStyle(fontSize: FmtFontSize.lg)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.flag_outlined, size: 16, color: FmtColors.muted),
            tooltip: 'Report this comment',
            onPressed: () => _promptFlagReason(context, ref, comment.id),
          ),
        ],
      ),
    );
  }

  Future<void> _promptFlagReason(
    BuildContext context,
    WidgetRef ref,
    String commentId,
  ) async {
    final controller = TextEditingController();
    final reason = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Flag this comment'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Why is this inappropriate?'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (controller.text.trim().isEmpty) return;
              Navigator.of(context).pop(controller.text.trim());
            },
            child: const Text('Flag'),
          ),
        ],
      ),
    );
    if (reason == null) return;
    await ref
        .read(commentRepositoryProvider)
        .flagComment(commentId, reason);
  }
}

class _CommentComposer extends ConsumerStatefulWidget {
  const _CommentComposer({required this.reportId});

  final String reportId;

  @override
  ConsumerState<_CommentComposer> createState() => _CommentComposerState();
}

class _CommentComposerState extends ConsumerState<_CommentComposer> {
  final _controller = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_controller.text.trim().isEmpty) return;
    setState(() => _submitting = true);
    try {
      await ref
          .read(commentRepositoryProvider)
          .postComment(widget.reportId, _controller.text);
      _controller.clear();
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            decoration: const InputDecoration(hintText: 'Add a comment…'),
            onSubmitted: (_) => _submit(),
          ),
        ),
        const SizedBox(width: FmtSpace.sm),
        IconButton(
          icon: _submitting
              ? const SizedBox.square(
                  dimension: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.send, color: FmtColors.brand),
          onPressed: _submitting ? null : _submit,
        ),
      ],
    );
  }
}
