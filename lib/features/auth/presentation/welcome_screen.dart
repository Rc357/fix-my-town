import 'package:fixmytown_citizen/app/theme/fmt_colors.dart';
import 'package:fixmytown_citizen/app/theme/fmt_spacing.dart';
import 'package:fixmytown_citizen/app/widgets/fmt_button.dart';
import 'package:fixmytown_citizen/app/widgets/map_preview.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(FmtSpace.xl),
          child: Column(
            children: [
              const Spacer(),
              const MapPreview(height: 180),
              const SizedBox(height: FmtSpace.xl),
              const Text(
                'FixMyTown',
                style: TextStyle(
                  fontSize: 28,
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
              PrimaryButton(
                label: 'Sign in',
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
                style: TextStyle(fontSize: 11, color: FmtColors.muted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
