import 'package:fixmytown_citizen/app/router/router_refresh_notifier.dart';
import 'package:fixmytown_citizen/features/auth/data/auth_providers.dart';
import 'package:fixmytown_citizen/features/auth/presentation/login_screen.dart';
import 'package:fixmytown_citizen/features/auth/presentation/profile_screen.dart';
import 'package:fixmytown_citizen/features/auth/presentation/welcome_screen.dart';
import 'package:fixmytown_citizen/features/home/presentation/home_screen.dart';
import 'package:fixmytown_citizen/features/incident_reporting/presentation/my_reports_screen.dart';
import 'package:fixmytown_citizen/features/incident_reporting/presentation/new_report/capture_screen.dart';
import 'package:fixmytown_citizen/features/incident_reporting/presentation/new_report/category_screen.dart';
import 'package:fixmytown_citizen/features/incident_reporting/presentation/new_report/review_screen.dart';
import 'package:fixmytown_citizen/features/incident_reporting/presentation/new_report/submitted_screen.dart';
import 'package:fixmytown_citizen/features/incident_reporting/presentation/report_detail_screen.dart';
import 'package:fixmytown_citizen/features/incident_reporting/presentation/track_by_id_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

abstract final class AppRoutes {
  static const welcome = '/welcome';
  static const login = '/login';
  static const home = '/home';
  static const track = '/track';
  static const myReports = '/reports';
  static const profile = '/profile';
  static const newReportCategory = '/reports/new/category';
  static const newReportCapture = '/reports/new/capture';
  static const newReportReview = '/reports/new/review';
  static const newReportSubmitted = '/reports/new/submitted';

  /// Requires signed-in access — a guest has no history to list (FR-1.1).
  static const _verifiedOnly = {myReports, profile};
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  final refreshNotifier = RouterRefreshNotifier(repository.authStateChanges());

  final router = GoRouter(
    initialLocation: AppRoutes.welcome,
    refreshListenable: refreshNotifier,
    redirect: (context, state) {
      final isSignedIn = repository.currentUser != null;
      final path = state.matchedLocation;

      if (path == AppRoutes.login) return isSignedIn ? AppRoutes.home : null;
      if (path == AppRoutes.welcome) return isSignedIn ? AppRoutes.home : null;
      if (AppRoutes._verifiedOnly.contains(path) && !isSignedIn) {
        return AppRoutes.login;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.welcome,
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.profile,
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.track,
        builder: (context, state) => const TrackByIdScreen(),
      ),
      GoRoute(
        path: AppRoutes.myReports,
        builder: (context, state) => const MyReportsScreen(),
      ),
      GoRoute(
        path: AppRoutes.newReportCategory,
        builder: (context, state) => const CategoryScreen(),
      ),
      GoRoute(
        path: AppRoutes.newReportCapture,
        builder: (context, state) => const CaptureScreen(),
      ),
      GoRoute(
        path: AppRoutes.newReportReview,
        builder: (context, state) => const ReviewScreen(),
      ),
      GoRoute(
        path: AppRoutes.newReportSubmitted,
        builder: (context, state) =>
            SubmittedScreen(trackingId: state.extra! as String),
      ),
      // Declared after the more specific /reports/... routes above so a
      // literal segment like /reports/new/category is never shadowed by
      // this catch-all id/tracking-id route.
      GoRoute(
        path: '/reports/:idOrTrackingId',
        builder: (context, state) => ReportDetailScreen(
          idOrTrackingId: state.pathParameters['idOrTrackingId']!,
        ),
      ),
    ],
  );

  ref.onDispose(() {
    router.dispose();
    refreshNotifier.dispose();
  });
  return router;
});
