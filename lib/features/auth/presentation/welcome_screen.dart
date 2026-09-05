import 'package:aninag_citizen/app/theme/aninag_colors.dart';
import 'package:aninag_citizen/app/theme/aninag_spacing.dart';
import 'package:aninag_citizen/app/widgets/aninag_button.dart';
import 'package:aninag_citizen/app/widgets/map_preview.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AninagSpace.xl),
          child: Column(
            children: [
              const Spacer(),
              const MapPreview(height: 180),
              const SizedBox(height: AninagSpace.xl),
              const Text(
                'Aninag',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AninagColors.brandInk,
                ),
              ),
              const SizedBox(height: AninagSpace.xs),
              const Text(
                'See it. Report it. Track it.',
                style: TextStyle(
                  color: AninagColors.muted,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              PrimaryButton(
                label: 'Sign in',
                onPressed: () => context.push('/login'),
              ),
              const SizedBox(height: AninagSpace.sm),
              OutlineButton(
                label: 'Continue as guest',
                onPressed: () => context.go('/home'),
              ),
              const SizedBox(height: AninagSpace.md),
              const Text(
                'Guest reports are tracked by ID only — sign in to get updates and history.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11, color: AninagColors.muted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
