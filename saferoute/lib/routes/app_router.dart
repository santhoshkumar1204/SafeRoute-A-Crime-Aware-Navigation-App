import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../features/landing/landing_page.dart';
import '../features/auth/login_page.dart';
import '../features/auth/signup_page.dart';
import '../features/auth/otp_verification_page.dart';
import '../features/dashboard/dashboard_shell.dart';
import '../features/dashboard/dashboard_home.dart';
import '../features/navigation/navigation_page.dart';
import '../features/heatmap/heatmap_page.dart';
import '../features/report/report_page.dart';
import '../features/analytics/analytics_page.dart';
import '../features/emergency/emergency_page.dart';
import '../features/settings/settings_page.dart';
import '../features/help/help_page.dart';
import '../features/trips/trips_page.dart';
import '../features/community/community_page.dart';
import '../features/transport/transport_types_page.dart';
import '../features/not_found/not_found_page.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: false,
    redirect: (context, state) {
      if (authState.status == AuthStatus.initial ||
          authState.status == AuthStatus.loading) {
        return null;
      }

      final isAuth = authState.isAuthenticated;
      final isAuthRoute = state.matchedLocation == '/login' ||
          state.matchedLocation == '/signup' ||
          state.matchedLocation == '/otp-verify';
      final isLanding = state.matchedLocation == '/';

      if (!isAuth && !isAuthRoute && !isLanding) {
        return '/login';
      }
      if (isAuth && isAuthRoute) {
        return '/dashboard';
      }
      return null;
    },
    errorBuilder: (context, state) => const NotFoundPage(),
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const LandingPage(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupPage(),
      ),
      GoRoute(
        path: '/otp-verify',
        builder: (context, state) {
          final email =
              state.uri.queryParameters['email'] ?? '';
          return OtpVerificationPage(email: email);
        },
      ),
      ShellRoute(
        builder: (context, state, child) => DashboardShell(child: child),
        routes: [
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => const DashboardHome(),
          ),
          GoRoute(
            path: '/navigation',
            builder: (context, state) => const NavigationPage(),
          ),
          GoRoute(
            path: '/heatmap',
            builder: (context, state) => const HeatmapPage(),
          ),
          GoRoute(
            path: '/report',
            builder: (context, state) => const ReportPage(),
          ),
          GoRoute(
            path: '/analytics',
            builder: (context, state) => const AnalyticsPage(),
          ),
          GoRoute(
            path: '/emergency',
            builder: (context, state) => const EmergencyPage(),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsPage(),
          ),
          GoRoute(
            path: '/help',
            builder: (context, state) => const HelpPage(),
          ),
          GoRoute(
            path: '/trips',
            builder: (context, state) => const TripsPage(),
          ),
          GoRoute(
            path: '/community',
            builder: (context, state) => const CommunityPage(),
          ),
          GoRoute(
            path: '/transport-types',
            builder: (context, state) => const TransportTypesPage(),
          ),
        ],
      ),
    ],
  );
});
