import 'package:aninag_citizen/app/theme/aninag_colors.dart';
import 'package:aninag_citizen/app/theme/aninag_spacing.dart';
import 'package:aninag_citizen/app/widgets/app_bottom_nav.dart';
import 'package:aninag_citizen/features/auth/data/auth_providers.dart';
import 'package:aninag_citizen/features/incident_reporting/data/report_providers.dart';
import 'package:aninag_citizen/features/incident_reporting/presentation/widgets/report_list_tile.dart';
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
            Icon(Icons.location_on, size: 18, color: AninagColors.brand),
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
              AninagSpace.lg,
              AninagSpace.lg,
              AninagSpace.lg,
              88,
            ),
            children: [
              Text(
                'REPORTED NEARBY',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: AninagSpace.sm),
              if (reports.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: AninagSpace.xl),
                  child: Text(
                    'No reports nearby yet.',
                    style: TextStyle(color: AninagColors.muted),
                  ),
                )
              else
                for (final report in reports) ...[
                  ReportListTile(
                    report: report,
                    onTap: () => context.push('/reports/${report.id}'),
                  ),
                  const SizedBox(height: AninagSpace.sm),
                ],
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/reports/new/category'),
        backgroundColor: AninagColors.brand,
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
