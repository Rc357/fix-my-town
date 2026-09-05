import 'package:fixmytown_citizen/app/theme/fmt_colors.dart';
import 'package:fixmytown_citizen/app/theme/fmt_spacing.dart';
import 'package:fixmytown_citizen/app/widgets/app_bottom_nav.dart';
import 'package:fixmytown_citizen/features/auth/data/auth_providers.dart';
import 'package:fixmytown_citizen/features/incident_reporting/data/report_providers.dart';
import 'package:fixmytown_citizen/features/incident_reporting/presentation/widgets/report_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportsAsync = ref.watch(nearbyReportsProvider);
    final isGuest = ref.watch(authRepositoryProvider).currentUser == null;

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.location_on, size: 18, color: FmtColors.brand),
            SizedBox(width: 6),
            Flexible(
              child: Text(
                'Brgy. San Isidro, Marikina City',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          if (isGuest)
            IconButton(
              tooltip: 'Track a report',
              onPressed: () => context.push('/track'),
              icon: const Icon(Icons.confirmation_number_outlined),
            ),
        ],
      ),
      body: SafeArea(
        child: reportsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) =>
              Center(child: Text('Something went wrong: $error')),
          data: (reports) => ListView(
            padding: const EdgeInsets.fromLTRB(
              FmtSpace.lg,
              FmtSpace.lg,
              FmtSpace.lg,
              88,
            ),
            children: [
              Text(
                'REPORTED NEARBY',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: FmtSpace.sm),
              if (reports.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: FmtSpace.xl),
                  child: Text(
                    'No reports nearby yet.',
                    style: TextStyle(color: FmtColors.muted),
                  ),
                )
              else
                for (final report in reports) ...[
                  ReportListTile(
                    report: report,
                    onTap: () => context.push('/reports/${report.id}'),
                  ),
                  const SizedBox(height: FmtSpace.sm),
                ],
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/reports/new/category'),
        backgroundColor: FmtColors.brand,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Report an issue',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
        ),
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 0),
    );
  }
}
