import 'package:aninag_citizen/app/theme/aninag_colors.dart';
import 'package:aninag_citizen/app/theme/aninag_spacing.dart';
import 'package:aninag_citizen/app/widgets/app_bottom_nav.dart';
import 'package:aninag_citizen/features/incident_reporting/data/report_providers.dart';
import 'package:aninag_citizen/features/incident_reporting/presentation/widgets/report_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(AninagSpace.xl),
                  child: Text(
                    "You haven't reported anything yet.",
                    style: TextStyle(color: AninagColors.muted),
                  ),
                ),
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(AninagSpace.lg),
              itemCount: reports.length,
              separatorBuilder: (context, index) =>
                  const SizedBox(height: AninagSpace.sm),
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
