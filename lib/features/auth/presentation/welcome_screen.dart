import 'package:fixmytown_citizen/app/theme/fmt_colors.dart';
import 'package:fixmytown_citizen/app/theme/fmt_spacing.dart';
import 'package:fixmytown_citizen/app/theme/fmt_text_styles.dart';
import 'package:fixmytown_citizen/app/widgets/fmt_button.dart';
import 'package:fixmytown_citizen/app/widgets/map_preview.dart';
import 'package:fixmytown_citizen/features/auth/presentation/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
          child: Column(
            children: [
              const Spacer(),
              const MapPreview(height: 180),
              const SizedBox(height: FmtSpace.xl),
              Text(
                'FixMyTown',
                style: TextStyle(
                  fontSize: FmtFontSize.display,
                  fontWeight: FontWeight.w800,
                  color: FmtColors.brandInk,
                ),
              ),
              const SizedBox(height: FmtSpace.xs),
              const Text(
                'See it. Report it. Track it.',
                style: TextStyle(
                  color: FmtColors.muted,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              OutlineButton(
                label: 'Continue with Google',
                icon: Icons.g_mobiledata,
                onPressed: authAction.isLoading
                    ? null
                    : () => ref
                          .read(authControllerProvider.notifier)
                          .signInWithGoogle(),
              ),
              const SizedBox(height: FmtSpace.sm),
              OutlineButton(
                label: 'Continue with Facebook',
                icon: Icons.facebook,
                onPressed: authAction.isLoading
                    ? null
                    : () => ref
                          .read(authControllerProvider.notifier)
                          .signInWithFacebook(),
              ),
              const SizedBox(height: FmtSpace.sm),
              PrimaryButton(
                label: 'Sign in with email',
                onPressed: () => context.push('/login'),
              ),
              const SizedBox(height: FmtSpace.sm),
              OutlineButton(
                label: 'Continue as guest',
                onPressed: () => context.go('/home'),
              ),
              const SizedBox(height: FmtSpace.md),
              const Text(
                'Guest reports are tracked by ID only — sign in to get updates and history.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: FmtFontSize.sm, color: FmtColors.muted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
