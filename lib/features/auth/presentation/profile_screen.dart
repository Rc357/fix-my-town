import 'package:aninag_citizen/app/theme/aninag_colors.dart';
import 'package:aninag_citizen/app/theme/aninag_spacing.dart';
import 'package:aninag_citizen/app/widgets/aninag_button.dart';
import 'package:aninag_citizen/app/widgets/app_bottom_nav.dart';
import 'package:aninag_citizen/features/auth/data/auth_providers.dart';
import 'package:aninag_citizen/features/auth/presentation/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authRepositoryProvider).currentUser;
    final authAction = ref.watch(authControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AninagSpace.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(AninagSpace.lg),
                decoration: BoxDecoration(
                  color: AninagColors.surface,
                  border: Border.all(color: AninagColors.line),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 24,
                      backgroundColor: AninagColors.brandTint,
                      child: Icon(Icons.person, color: AninagColors.brandInk),
                    ),
                    const SizedBox(width: AninagSpace.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Verified Citizen',
                            style: TextStyle(fontWeight: FontWeight.w800),
                          ),
                          Text(
                            user?.email ?? '',
                            style: const TextStyle(
                              color: AninagColors.muted,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AninagSpace.xl),
              OutlineButton(
                label: authAction.isLoading ? 'Signing out…' : 'Sign out',
                onPressed: authAction.isLoading
                    ? null
                    : () => ref.read(authControllerProvider.notifier).signOut(),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 2),
    );
  }
}
