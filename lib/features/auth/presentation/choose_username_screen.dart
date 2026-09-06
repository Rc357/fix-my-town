import 'dart:math';

import 'package:fixmytown_citizen/app/theme/fmt_colors.dart';
import 'package:fixmytown_citizen/app/theme/fmt_spacing.dart';
import 'package:fixmytown_citizen/app/widgets/fmt_button.dart';
import 'package:fixmytown_citizen/features/auth/presentation/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// FR-16.3 — the mandatory post-OAuth gate. Reached only when the signed-in
/// user's `username` is null (Google/Facebook first-time sign-in); the
/// router's redirect logic forces this screen and nothing else is reachable
/// until it's completed, same enforcement style as the existing
/// `_verifiedOnly` guard in app_router.dart.
///
/// The suggested pseudonym is pre-filled so accepting it is one tap, not
/// friction — this is what keeps "anonymous by default" (FR-16.2) practical
/// rather than merely aspirational.
class ChooseUsernameScreen extends ConsumerStatefulWidget {
  const ChooseUsernameScreen({super.key});

  @override
  ConsumerState<ChooseUsernameScreen> createState() => _ChooseUsernameScreenState();
}

class _ChooseUsernameScreenState extends ConsumerState<ChooseUsernameScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _controller = TextEditingController(text: _suggestPseudonym());

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _suggestPseudonym() => 'Citizen${1000 + Random().nextInt(9000)}';

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    await ref.read(authControllerProvider.notifier).completeUsername(_controller.text);
  }

  @override
  Widget build(BuildContext context) {
    final authAction = ref.watch(authControllerProvider);

    ref.listen(authControllerProvider, (previous, next) {
      if (next case AsyncError(:final error)) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(error.toString())));
      }
    });

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(FmtSpace.xl),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: FmtSpace.xxl),
                Text(
                  'Choose a username',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: FmtSpace.sm),
                const Text(
                  'This is what other citizens see — we\'ve suggested one '
                  'below so you can stay anonymous, or pick your own. Your '
                  'real name is never shown unless you turn that on later, '
                  'in your profile.',
                  style: TextStyle(color: FmtColors.muted),
                ),
                const SizedBox(height: FmtSpace.xl),
                TextFormField(
                  controller: _controller,
                  autofocus: true,
                  decoration: const InputDecoration(labelText: 'Username'),
                  validator: (value) =>
                      (value?.trim().isNotEmpty ?? false) ? null : 'Choose a username.',
                ),
                const SizedBox(height: FmtSpace.lg),
                PrimaryButton(
                  label: 'Continue',
                  loading: authAction.isLoading,
                  onPressed: _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
