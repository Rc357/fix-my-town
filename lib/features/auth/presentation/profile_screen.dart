import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:obserba/app/theme/obs_colors.dart';
import 'package:obserba/app/theme/obs_spacing.dart';
import 'package:obserba/app/theme/obs_text_styles.dart';
import 'package:obserba/app/theme/theme_mode_controller.dart';
import 'package:obserba/app/widgets/app_bottom_nav.dart';
import 'package:obserba/app/widgets/obs_button.dart';
import 'package:obserba/features/auth/data/auth_providers.dart';
import 'package:obserba/features/auth/presentation/auth_controller.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authRepositoryProvider).currentUser;
    final authAction = ref.watch(authControllerProvider);
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(ObsSpace.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(ObsSpace.lg),
                decoration: BoxDecoration(
                  color: ObsColors.surface,
                  border: Border.all(color: ObsColors.line),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: ObsColors.brandTint,
                      child: Icon(Icons.person, color: ObsColors.brandInk),
                    ),
                    const SizedBox(width: ObsSpace.md),
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
                            style: TextStyle(
                              color: ObsColors.muted,
                              fontSize: ObsFontSize.md,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: ObsSpace.lg),
              // FR-16.2 — off by default; this is the only place it can be
              // turned on. What other users see is username-first regardless
              // of this switch (AppUser.publicDisplayName handles the logic).
              Container(
                padding: const EdgeInsets.all(ObsSpace.lg),
                decoration: BoxDecoration(
                  color: ObsColors.surface,
                  border: Border.all(color: ObsColors.line),
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
                            style: TextStyle(
                              color: ObsColors.muted,
                              fontSize: ObsFontSize.md,
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
              const SizedBox(height: ObsSpace.lg),
              Container(
                padding: const EdgeInsets.all(ObsSpace.lg),
                decoration: BoxDecoration(
                  color: ObsColors.surface,
                  border: Border.all(color: ObsColors.line),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Appearance',
                      style: TextStyle(fontWeight: FontWeight.w800, color: ObsColors.ink),
                    ),
                    const SizedBox(height: ObsSpace.sm),
                    SegmentedButton<ThemeMode>(
                      segments: const [
                        ButtonSegment(
                          value: ThemeMode.light,
                          label: Text('Light'),
                          icon: Icon(Icons.light_mode_outlined),
                        ),
                        ButtonSegment(
                          value: ThemeMode.dark,
                          label: Text('Dark'),
                          icon: Icon(Icons.dark_mode_outlined),
                        ),
                        ButtonSegment(
                          value: ThemeMode.system,
                          label: Text('System'),
                          icon: Icon(Icons.brightness_auto_outlined),
                        ),
                      ],
                      selected: {themeMode},
                      onSelectionChanged: (selected) => ref
                          .read(themeModeProvider.notifier)
                          .setThemeMode(selected.first),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: ObsSpace.xl),
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
      bottomNavigationBar: const AppBottomNav(currentIndex: 3),
    );
  }
}
