import 'package:fixmytown_citizen/app/theme/fmt_colors.dart';
import 'package:fixmytown_citizen/app/theme/fmt_spacing.dart';
import 'package:fixmytown_citizen/app/widgets/fmt_button.dart';
import 'package:fixmytown_citizen/app/widgets/stepper_dots.dart';
import 'package:fixmytown_citizen/features/incident_reporting/domain/report_category.dart';
import 'package:fixmytown_citizen/features/incident_reporting/presentation/new_report/new_report_controller.dart';
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
          padding: const EdgeInsets.all(FmtSpace.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const StepperDots(total: 3, currentIndex: 2),
              const SizedBox(height: FmtSpace.lg),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'DESCRIPTION (OPTIONAL)',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      const SizedBox(height: FmtSpace.sm),
                      TextField(
                        controller: _descriptionController,
                        maxLines: 4,
                        maxLength: 280,
                        decoration: const InputDecoration(
                          hintText:
                              'Anything staff should know before they respond?',
                        ),
                      ),
                      const SizedBox(height: FmtSpace.md),
                      Text(
                        'REVIEW',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      const SizedBox(height: FmtSpace.sm),
                      Container(
                        padding: const EdgeInsets.all(FmtSpace.md),
                        decoration: BoxDecoration(
                          color: FmtColors.surface,
                          border: Border.all(color: FmtColors.line),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: FmtColors.brandTint,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                category?.icon ?? Icons.help_outline,
                                color: FmtColors.brandInk,
                              ),
                            ),
                            const SizedBox(width: FmtSpace.md),
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
                                      color: FmtColors.muted,
                                    ),
                                  ),
                                  const Text(
                                    '1 photo attached',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: FmtColors.muted,
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
              const SizedBox(height: FmtSpace.lg),
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
