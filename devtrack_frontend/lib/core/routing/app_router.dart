import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/providers/auth_state.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/home/presentation/screens/analytics_dashboard_screen.dart';
import '../../features/internship/domain/entities/internship.dart';
import '../../features/internship/presentation/screens/internship_list_screen.dart';
import '../../features/internship/presentation/screens/internship_form_screen.dart';
import '../../features/dsa/domain/entities/dsa_topic.dart';
import '../../features/dsa/presentation/screens/dsa_screen.dart';
import '../../features/dsa/presentation/screens/dsa_form_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authNotifierProvider);

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final isAuthenticated = authState.status == AuthStatus.authenticated;
      final isAuthRoute = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';

      if (authState.status == AuthStatus.initial) return null;
      if (isAuthenticated && isAuthRoute) return '/home';
      if (!isAuthenticated && !isAuthRoute) return '/login';
      return null;
    },
    routes: [
      // ── Auth ──────────────────────────────────────────────────────────
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),

      // ── Home ──────────────────────────────────────────────────────────
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),

      // ── Internships ───────────────────────────────────────────────────
      GoRoute(
        path: '/internships',
        builder: (context, state) => const InternshipListScreen(),
      ),
      GoRoute(
        path: '/internships/add',
        builder: (context, state) => const InternshipFormScreen(),
      ),
      GoRoute(
        path: '/internships/edit',
        builder: (context, state) {
          final internship = state.extra as Internship?;
          return InternshipFormScreen(internship: internship);
        },
      ),

      // ── DSA Tracker ───────────────────────────────────────────────────
      GoRoute(
        path: '/dsa',
        builder: (context, state) => const DsaScreen(),
      ),
      GoRoute(
        path: '/dsa/add',
        builder: (context, state) => const DsaFormScreen(),
      ),
      GoRoute(
        path: '/dsa/edit',
        builder: (context, state) {
          final topic = state.extra as DsaTopic?;
          return DsaFormScreen(topic: topic);
        },
      ),

      // ── Analytics & Charts Dashboard ──────────────────────────────────
      GoRoute(
        path: '/analytics',
        builder: (context, state) => const AnalyticsDashboardScreen(),
      ),
    ],
  );
});
