import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:obserba/app/theme/obs_colors.dart';
import 'package:obserba/app/theme/obs_spacing.dart';
import 'package:obserba/app/theme/obs_text_styles.dart';
import 'package:obserba/app/widgets/obs_button.dart';
import 'package:obserba/app/widgets/stepper_dots.dart';
import 'package:obserba/features/incident_reporting/data/category_providers.dart';
import 'package:obserba/features/incident_reporting/domain/report_category.dart';
import 'package:obserba/features/incident_reporting/presentation/new_report/new_report_controller.dart';

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
    final categoriesAsync = ref.watch(categoriesProvider);
    final category = draft.categoryId != null
        ? categoriesAsync.value?.byId(draft.categoryId!)
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
          padding: const EdgeInsets.all(ObsSpace.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const StepperDots(total: 3, currentIndex: 2),
              const SizedBox(height: ObsSpace.lg),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'DESCRIPTION (OPTIONAL)',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      const SizedBox(height: ObsSpace.sm),
                      TextField(
                        controller: _descriptionController,
                        maxLines: 4,
                        maxLength: 280,
                        decoration: const InputDecoration(
                          hintText:
                              'Anything staff should know before they respond?',
                        ),
                      ),
                      const SizedBox(height: ObsSpace.md),
                      Text(
                        'REVIEW',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      const SizedBox(height: ObsSpace.sm),
                      Container(
                        padding: const EdgeInsets.all(ObsSpace.md),
                        decoration: BoxDecoration(
                          color: ObsColors.surface,
                          border: Border.all(color: ObsColors.line),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: ObsColors.brandTint,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                category?.icon ?? Icons.help_outline,
                                color: ObsColors.brandInk,
                              ),
                            ),
                            const SizedBox(width: ObsSpace.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    category?.label ?? '',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: ObsFontSize.lg,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    draft.formattedLocation,
                                    style: TextStyle(
                                      fontSize: ObsFontSize.sm,
                                      color: ObsColors.muted,
                                    ),
                                  ),
                                  Text(
                                    draft.hasVideo
                                        ? 'Video attached (${draft.videoDurationSeconds}s)'
                                        : '${draft.photoPaths.length} photo${draft.photoPaths.length == 1 ? '' : 's'} attached',
                                    style: TextStyle(
                                      fontSize: ObsFontSize.sm,
                                      color: ObsColors.muted,
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
              const SizedBox(height: ObsSpace.lg),
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
