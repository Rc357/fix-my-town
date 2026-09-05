import 'package:fixmytown_citizen/app/theme/fmt_colors.dart';
import 'package:fixmytown_citizen/app/theme/fmt_spacing.dart';
import 'package:fixmytown_citizen/app/widgets/fmt_button.dart';
import 'package:fixmytown_citizen/app/widgets/workflow_timeline.dart';
import 'package:fixmytown_citizen/features/incident_reporting/data/report_providers.dart';
import 'package:fixmytown_citizen/features/incident_reporting/domain/report.dart';
import 'package:fixmytown_citizen/features/incident_reporting/domain/report_category.dart';
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
    final category = ReportCategories.byId(report.categoryId);

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
                    Text(
                      category.label,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15.5,
                      ),
                    ),
                    Text(
                      report.trackingId,
                      style: const TextStyle(
                        fontSize: 11,
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
                        fontSize: 12.5,
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
                  Text(report.address, style: const TextStyle(fontSize: 12.5)),
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
