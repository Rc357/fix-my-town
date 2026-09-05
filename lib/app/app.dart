import 'package:fixmytown_citizen/app/config/app_config.dart';
import 'package:fixmytown_citizen/app/router/app_router.dart';
import 'package:fixmytown_citizen/app/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
