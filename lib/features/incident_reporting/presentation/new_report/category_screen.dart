import 'package:aninag_citizen/app/theme/aninag_spacing.dart';
import 'package:aninag_citizen/app/widgets/aninag_button.dart';
import 'package:aninag_citizen/app/widgets/category_tile.dart';
import 'package:aninag_citizen/app/widgets/stepper_dots.dart';
import 'package:aninag_citizen/features/incident_reporting/domain/report_category.dart';
import 'package:aninag_citizen/features/incident_reporting/presentation/new_report/new_report_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class CategoryScreen extends ConsumerWidget {
  const CategoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(newReportControllerProvider);
    final controller = ref.read(newReportControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text("What's the issue?")),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AninagSpace.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const StepperDots(total: 3, currentIndex: 0),
              const SizedBox(height: AninagSpace.lg),
              Expanded(
                child: GridView.builder(
                  itemCount: ReportCategories.all.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: AninagSpace.sm,
                    crossAxisSpacing: AninagSpace.sm,
                    childAspectRatio: 0.92,
                  ),
                  itemBuilder: (context, index) {
                    final category = ReportCategories.all[index];
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
              const SizedBox(height: AninagSpace.lg),
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
