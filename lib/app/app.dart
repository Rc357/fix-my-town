import 'package:fixmytown_citizen/app/config/app_config.dart';
import 'package:fixmytown_citizen/app/router/app_router.dart';
import 'package:fixmytown_citizen/app/theme/app_theme.dart';
import 'package:fixmytown_citizen/features/notifications/data/notification_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

    return MaterialApp.router(
      title: config.appName,
      debugShowCheckedModeBanner: config.flavor != AppFlavor.production,
      theme: AppTheme.theme,
      routerConfig: router,
    );
  }
}
