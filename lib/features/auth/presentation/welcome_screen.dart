import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:obserba/app/theme/obs_colors.dart';
import 'package:obserba/app/theme/obs_spacing.dart';
import 'package:obserba/app/theme/obs_text_styles.dart';
import 'package:obserba/app/widgets/map_preview.dart';
import 'package:obserba/app/widgets/obs_button.dart';
import 'package:obserba/features/auth/presentation/auth_controller.dart';

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
          padding: const EdgeInsets.all(ObsSpace.xl),
          child: Column(
            children: [
              const Spacer(),
              const MapPreview(height: 180),
              const SizedBox(height: ObsSpace.xl),
              Text(
                'Obserba',
                style: TextStyle(
                  fontSize: ObsFontSize.display,
                  fontWeight: FontWeight.w800,
                  color: ObsColors.brandInk,
                ),
              ),
              const SizedBox(height: ObsSpace.xs),
              Text(
                'See it. Report it. Track it.',
                style: TextStyle(
                  color: ObsColors.muted,
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
              const SizedBox(height: ObsSpace.sm),
              OutlineButton(
                label: 'Continue with Facebook',
                icon: Icons.facebook,
                onPressed: authAction.isLoading
                    ? null
                    : () => ref
                          .read(authControllerProvider.notifier)
                          .signInWithFacebook(),
              ),
              const SizedBox(height: ObsSpace.sm),
              PrimaryButton(
                label: 'Sign in with email',
                onPressed: () => context.push('/login'),
              ),
              const SizedBox(height: ObsSpace.sm),
              OutlineButton(
                label: 'Continue as guest',
                onPressed: () => context.go('/home'),
              ),
              const SizedBox(height: ObsSpace.md),
              Text(
                'Guest reports are tracked by ID only — sign in to get updates and history.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: ObsFontSize.sm, color: ObsColors.muted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
