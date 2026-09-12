import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:obserba/app/config/app_config.dart';
import 'package:obserba/app/router/app_router.dart';
import 'package:obserba/app/theme/app_theme.dart';
import 'package:obserba/app/theme/obs_colors.dart';
import 'package:obserba/app/theme/theme_mode_controller.dart';
import 'package:obserba/features/notifications/data/notification_providers.dart';

class App extends ConsumerStatefulWidget {
  const App({super.key});

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> {
  @override
  void initState() {
    super.initState();
    // Deferred to after the first frame: push init needs the router (to
    // navigate on a notification tap), and reading providers inside
    // initState — before the widget tree this state belongs to has
    // actually built — risks reading a stale/uninitialized provider graph.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final config = ref.read(appConfigProvider);
      if (!config.hasFirebase) return;
      ref
          .read(pushNotificationServiceProvider)
          .init(ref.read(appRouterProvider));
    });
  }

  @override
  Widget build(BuildContext context) {
    final config = ref.watch(appConfigProvider);
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeModeProvider);

    // Resolved once per build, here — not deeper in the tree — so it's set
    // before AppTheme.theme (evaluated below, in the same build) reads it.
    // `MediaQuery.platformBrightnessOf` works at this level: runApp() wraps
    // the root widget in a View that supplies platform MediaQuery data
    // regardless of MaterialApp existing yet.
    final resolvedBrightness = switch (themeMode) {
      ThemeMode.light => Brightness.light,
      ThemeMode.dark => Brightness.dark,
      ThemeMode.system => MediaQuery.platformBrightnessOf(context),
    };
    ObsColors.setBrightness(resolvedBrightness);

    return MaterialApp.router(
      // Every screen in this app reads colors via ObsColors' static
      // getters, not Theme.of(context) — so nothing would otherwise know
      // to rebuild when brightness flips. Keying the whole app on the
      // resolved brightness forces a full remount instead, which is the
      // deliberate trade for not having to convert every widget to read
      // colors through the theme/context: switching Light/Dark/System
      // resets in-progress navigation state (scroll position, unsaved
      // form fields), acceptable for a rare settings action.
      key: ValueKey(resolvedBrightness),
      title: config.appName,
      debugShowCheckedModeBanner: config.flavor != AppFlavor.production,
      theme: AppTheme.theme,
      routerConfig: router,
    );
  }
}
