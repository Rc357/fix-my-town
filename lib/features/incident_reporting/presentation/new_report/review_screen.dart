import 'package:aninag_citizen/app/theme/aninag_colors.dart';
import 'package:aninag_citizen/app/theme/aninag_spacing.dart';
import 'package:aninag_citizen/app/widgets/aninag_button.dart';
import 'package:aninag_citizen/app/widgets/stepper_dots.dart';
import 'package:aninag_citizen/features/incident_reporting/domain/report_category.dart';
import 'package:aninag_citizen/features/incident_reporting/presentation/new_report/new_report_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ReviewScreen extends ConsumerStatefulWidget {
  const ReviewScreen({super.key});

  @override
  ConsumerState<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends ConsumerState<ReviewScreen> {
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final controller = ref.read(newReportControllerProvider.notifier);
    controller.setDescription(_descriptionController.text);
    final report = await controller.submit();
    if (report != null && mounted) {
      context.go('/reports/new/submitted', extra: report.trackingId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(newReportControllerProvider);
    final category = draft.categoryId != null
        ? ReportCategories.byId(draft.categoryId!)
        : null;

    ref.listen(newReportControllerProvider, (previous, next) {
      if (next.error != null && next.error != previous?.error) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(next.error!)));
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Add details')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AninagSpace.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const StepperDots(total: 3, currentIndex: 2),
              const SizedBox(height: AninagSpace.lg),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'DESCRIPTION (OPTIONAL)',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      const SizedBox(height: AninagSpace.sm),
                      TextField(
                        controller: _descriptionController,
                        maxLines: 4,
                        maxLength: 280,
                        decoration: const InputDecoration(
                          hintText:
                              'Anything staff should know before they respond?',
                        ),
                      ),
                      const SizedBox(height: AninagSpace.md),
                      Text(
                        'REVIEW',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      const SizedBox(height: AninagSpace.sm),
                      Container(
                        padding: const EdgeInsets.all(AninagSpace.md),
                        decoration: BoxDecoration(
                          color: AninagColors.surface,
                          border: Border.all(color: AninagColors.line),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: AninagColors.brandTint,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                category?.icon ?? Icons.help_outline,
                                color: AninagColors.brandInk,
                              ),
                            ),
                            const SizedBox(width: AninagSpace.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    category?.label ?? '',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    draft.formattedLocation,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AninagColors.muted,
                                    ),
                                  ),
                                  const Text(
                                    '1 photo attached',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: AninagColors.muted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AninagSpace.lg),
              PrimaryButton(
                label: 'Submit report',
                loading: draft.isSubmitting,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
