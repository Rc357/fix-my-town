import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:obserba/app/theme/obs_colors.dart';
import 'package:obserba/app/theme/obs_spacing.dart';
import 'package:obserba/app/theme/obs_text_styles.dart';
import 'package:obserba/app/widgets/app_bottom_nav.dart';
import 'package:obserba/features/auth/data/auth_providers.dart';
import 'package:obserba/features/auth/domain/barangay.dart';
import 'package:obserba/features/incident_reporting/data/report_providers.dart';
import 'package:obserba/features/incident_reporting/presentation/widgets/report_feed_post.dart';

/// FR-20.1 — the scrollable feed is the primary citizen-facing surface now,
/// not an incidental list. Pull-to-refresh (via ref.invalidate) is the
/// feed's refresh mechanism — see SupabaseReportRepository's class doc for
/// why this isn't a live realtime subscription.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportsAsync = ref.watch(nearbyReportsProvider);
    final isGuest = ref.watch(authRepositoryProvider).currentUser == null;

    return Scaffold(
      backgroundColor: ObsColors.surface,
      appBar: AppBar(
        title: const _BarangaySelector(),
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
          data: (reports) => RefreshIndicator(
            onRefresh: () async => ref.invalidate(nearbyReportsProvider),
            child: reports.isEmpty
                ? ListView(
                    // A ListView (not a Center) so pull-to-refresh still
                    // works on an empty feed — RefreshIndicator needs a
                    // scrollable child to detect the pull gesture at all.
                    padding: const EdgeInsets.only(top: 120, bottom: 88),
                    children: [
                      Center(
                        child: Text(
                          'No reports nearby yet.\nPull down to refresh.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: ObsColors.muted),
                        ),
                      ),
                    ],
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(
                      ObsSpace.md,
                      ObsSpace.md,
                      ObsSpace.md,
                      88,
                    ),
                    itemCount: reports.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: ObsSpace.md),
                    itemBuilder: (context, index) {
                      final report = reports[index];
                      return ReportFeedPost(
                        report: report,
                        onTap: () => context.push('/reports/${report.id}'),
                      );
                    },
                  ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/reports/new/category'),
        backgroundColor: ObsColors.brand,
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

/// Manual barangay picker — there's no `barangay_boundary` polygon data to
/// GPS-resolve against (see CategoryRepository's sibling design note), so
/// this is how a citizen's "home" barangay gets set instead. Disabled for
/// guests: setBarangay needs a user_account row, which a guest doesn't have.
class _BarangaySelector extends ConsumerWidget {
  const _BarangaySelector();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authRepositoryProvider).currentUser;
    final barangaysAsync = ref.watch(barangaysProvider);

    if (user == null) {
      return Row(
        children: [
          Icon(Icons.location_on_outlined, size: 18, color: ObsColors.muted),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              'Sign in to set your barangay',
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: ObsFontSize.md,
                color: ObsColors.muted,
              ),
            ),
          ),
        ],
      );
    }

    final label = barangaysAsync.value == null
        ? 'Loading…'
        : user.barangayId == null
        ? 'Select your barangay'
        : barangaysAsync.value!
              .firstWhere(
                (b) => b.id == user.barangayId,
                orElse: () => const Barangay(id: '', name: 'Barangay'),
              )
              .name;

    return InkWell(
      onTap: () => _showBarangayPicker(context, ref),
      child: Row(
        children: [
          Icon(Icons.location_on, size: 18, color: ObsColors.brand),
          const SizedBox(width: 6),
          Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
          Icon(Icons.expand_more, size: 18, color: ObsColors.muted),
        ],
      ),
    );
  }

  Future<void> _showBarangayPicker(BuildContext context, WidgetRef ref) {
    return showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        final barangaysAsync = ref.watch(barangaysProvider);
        return SafeArea(
          child: barangaysAsync.when(
            loading: () => const SizedBox(
              height: 120,
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, stackTrace) => Padding(
              padding: const EdgeInsets.all(ObsSpace.lg),
              child: Text("Couldn't load barangays: $error"),
            ),
            data: (barangays) => ListView(
              shrinkWrap: true,
              children: [
                Padding(
                  padding: const EdgeInsets.all(ObsSpace.md),
                  child: Text(
                    'SELECT YOUR BARANGAY',
                    style: TextStyle(
                      fontSize: ObsFontSize.sm,
                      fontWeight: FontWeight.w700,
                      color: ObsColors.muted,
                      letterSpacing: 0.6,
                    ),
                  ),
                ),
                for (final barangay in barangays)
                  ListTile(
                    title: Text(barangay.name),
                    onTap: () async {
                      Navigator.of(context).pop();
                      await ref
                          .read(authRepositoryProvider)
                          .setBarangay(barangay.id);
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
