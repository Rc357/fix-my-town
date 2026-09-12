import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:obserba/app/theme/obs_colors.dart';
import 'package:obserba/app/theme/obs_spacing.dart';
import 'package:obserba/app/widgets/app_bottom_nav.dart';
import 'package:obserba/features/incident_reporting/data/report_providers.dart';
import 'package:obserba/features/incident_reporting/presentation/widgets/report_list_tile.dart';

class MyReportsScreen extends ConsumerWidget {
  const MyReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportsAsync = ref.watch(myReportsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My Reports')),
      body: SafeArea(
        child: reportsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) =>
              Center(child: Text('Something went wrong: $error')),
          data: (reports) {
            if (reports.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(ObsSpace.xl),
                  child: Text(
                    "You haven't reported anything yet.",
                    style: TextStyle(color: ObsColors.muted),
                  ),
                ),
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(ObsSpace.lg),
              itemCount: reports.length,
              separatorBuilder: (context, index) =>
                  const SizedBox(height: ObsSpace.sm),
              itemBuilder: (context, index) {
                final report = reports[index];
                return ReportListTile(
                  report: report,
                  onTap: () => context.push('/reports/${report.id}'),
                );
              },
            );
          },
        ),
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 1),
    );
  }
}
