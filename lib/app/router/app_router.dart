import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:obserba/app/router/router_refresh_notifier.dart';
import 'package:obserba/features/auth/data/auth_providers.dart';
import 'package:obserba/features/auth/presentation/choose_username_screen.dart';
import 'package:obserba/features/auth/presentation/login_screen.dart';
import 'package:obserba/features/auth/presentation/profile_screen.dart';
import 'package:obserba/features/auth/presentation/signup_screen.dart';
import 'package:obserba/features/auth/presentation/welcome_screen.dart';
import 'package:obserba/features/home/presentation/home_screen.dart';
import 'package:obserba/features/incident_reporting/presentation/my_reports_screen.dart';
import 'package:obserba/features/incident_reporting/presentation/new_report/capture_screen.dart';
import 'package:obserba/features/incident_reporting/presentation/new_report/category_screen.dart';
import 'package:obserba/features/incident_reporting/presentation/new_report/review_screen.dart';
import 'package:obserba/features/incident_reporting/presentation/new_report/submitted_screen.dart';
import 'package:obserba/features/incident_reporting/presentation/report_detail_screen.dart';
import 'package:obserba/features/incident_reporting/presentation/track_by_id_screen.dart';
import 'package:obserba/features/notifications/presentation/notifications_screen.dart';

abstract final class AppRoutes {
  static const welcome = '/welcome';
  static const login = '/login';
  static const signup = '/signup';
  static const chooseUsername = '/choose-username';
  static const home = '/home';
  static const track = '/track';
  static const myReports = '/reports';
  static const notifications = '/notifications';
  static const profile = '/profile';
  static const newReportCategory = '/reports/new/category';
  static const newReportCapture = '/reports/new/capture';
  static const newReportReview = '/reports/new/review';
  static const newReportSubmitted = '/reports/new/submitted';

  /// Requires signed-in access — a guest has no history to list (FR-1.1),
  /// and no notifications either (nothing to notify a user_account-less
  /// account about).
  static const _verifiedOnly = {myReports, notifications, profile};

  /// Reachable regardless of the username-completion gate below — a signed-in
  /// user with no username yet must be able to reach chooseUsername itself
  /// and sign out, nothing else (FR-16.3).
  static const _usernameGateExempt = {welcome, login, signup, chooseUsername};
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  final refreshNotifier = RouterRefreshNotifier(repository.authStateChanges());

  final router = GoRouter(
    initialLocation: AppRoutes.welcome,
    refreshListenable: refreshNotifier,
    redirect: (context, state) {
      final user = repository.currentUser;
      final isSignedIn = user != null;
      final path = state.matchedLocation;

      if (path == AppRoutes.login) return isSignedIn ? AppRoutes.home : null;
      if (path == AppRoutes.signup) return isSignedIn ? AppRoutes.home : null;
      if (path == AppRoutes.welcome) return isSignedIn ? AppRoutes.home : null;
      // FR-16.3 — a signed-in OAuth account with no username yet can't reach
      // anything else until this completes. Checked before _verifiedOnly so
      // it wins even on a route that would otherwise be allowed.
      if (isSignedIn &&
          user.needsUsername &&
          !AppRoutes._usernameGateExempt.contains(path)) {
        return AppRoutes.chooseUsername;
      }
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
        path: AppRoutes.signup,
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: AppRoutes.chooseUsername,
        builder: (context, state) => const ChooseUsernameScreen(),
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
        path: AppRoutes.notifications,
        builder: (context, state) => const NotificationsScreen(),
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
