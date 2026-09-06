import 'package:fixmytown_citizen/app/theme/fmt_colors.dart';
import 'package:fixmytown_citizen/app/theme/fmt_spacing.dart';
import 'package:fixmytown_citizen/app/theme/fmt_text_styles.dart';
import 'package:fixmytown_citizen/app/widgets/app_bottom_nav.dart';
import 'package:fixmytown_citizen/app/widgets/fmt_button.dart';
import 'package:fixmytown_citizen/features/auth/data/auth_providers.dart';
import 'package:fixmytown_citizen/features/auth/presentation/auth_controller.dart';
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
          padding: const EdgeInsets.all(FmtSpace.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(FmtSpace.lg),
                decoration: BoxDecoration(
                  color: FmtColors.surface,
                  border: Border.all(color: FmtColors.line),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: FmtColors.brandTint,
                      child: Icon(Icons.person, color: FmtColors.brandInk),
                    ),
                    const SizedBox(width: FmtSpace.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.username ?? 'Verified Citizen',
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                          Text(
                            user?.email ?? '',
                            style: const TextStyle(
                              color: FmtColors.muted,
                              fontSize: FmtFontSize.md,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: FmtSpace.lg),
              // FR-16.2 — off by default; this is the only place it can be
              // turned on. What other users see is username-first regardless
              // of this switch (AppUser.publicDisplayName handles the logic).
              Container(
                padding: const EdgeInsets.all(FmtSpace.lg),
                decoration: BoxDecoration(
                  color: FmtColors.surface,
                  border: Border.all(color: FmtColors.line),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Show my real name',
                            style: TextStyle(fontWeight: FontWeight.w800),
                          ),
                          Text(
                            user?.realName == null
                                ? 'Only available for Google/Facebook sign-in.'
                                : 'Shown instead of your username to other citizens.',
                            style: const TextStyle(
                              color: FmtColors.muted,
                              fontSize: FmtFontSize.md,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: user?.showRealName ?? false,
                      onChanged: user?.realName == null
                          ? null
                          : (value) => ref
                                .read(authControllerProvider.notifier)
                                .setShowRealName(value),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: FmtSpace.xl),
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
