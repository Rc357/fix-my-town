import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:obserba/app/theme/obs_colors.dart';
import 'package:obserba/app/theme/obs_spacing.dart';
import 'package:obserba/app/widgets/category_tile.dart';
import 'package:obserba/app/widgets/obs_button.dart';
import 'package:obserba/app/widgets/stepper_dots.dart';
import 'package:obserba/features/incident_reporting/data/category_providers.dart';
import 'package:obserba/features/incident_reporting/presentation/new_report/new_report_controller.dart';

class CategoryScreen extends ConsumerWidget {
  const CategoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(newReportControllerProvider);
    final controller = ref.read(newReportControllerProvider.notifier);
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("What's the issue?")),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(ObsSpace.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const StepperDots(total: 3, currentIndex: 0),
              const SizedBox(height: ObsSpace.lg),
              Expanded(
                child: categoriesAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, stackTrace) => Center(
                    child: Text(
                      "Couldn't load categories: $error",
                      style: TextStyle(color: ObsColors.muted),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  data: (categories) => GridView.builder(
                    itemCount: categories.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: ObsSpace.sm,
                      crossAxisSpacing: ObsSpace.sm,
                      childAspectRatio: 0.92,
                    ),
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      return CategoryTile(
                        icon: category.icon,
                        label: category.label,
                        isPriority: category.isPriority,
                        selected: draft.categoryId == category.id,
                        onTap: () => controller.selectCategory(category.id),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: ObsSpace.lg),
              PrimaryButton(
                label: 'Next',
                onPressed: draft.hasCategory
                    ? () => context.push('/reports/new/capture')
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
