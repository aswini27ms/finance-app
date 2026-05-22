import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/splash/splash_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/signup_screen.dart';
import '../features/auth/otp_screen.dart';
import '../features/dashboard/dashboard_screen.dart';
import '../features/folders/folders_screen.dart';
import '../features/wishlist/wishlist_screen.dart';
import '../features/analytics/analytics_screen.dart';
import '../features/ai_coach/ai_coach_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/transactions/transactions_screen.dart';
import '../shared/components/main_shell.dart';
import '../services/auth_provider.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final isAuth = authState.isAuthenticated;
      final isLoading = authState.isLoading;

      // Don't redirect while loading auth state
      if (isLoading) return null;

      final publicRoutes = [
        '/splash',
        '/onboarding',
        '/login',
        '/signup',
        '/otp'
      ];
      final isPublic =
          publicRoutes.any((r) => state.matchedLocation.startsWith(r));

      // Redirect unauthenticated users away from protected routes
      if (!isAuth && !isPublic) return '/login';

      // Redirect authenticated users away from auth screens
      if (isAuth &&
          (state.matchedLocation == '/login' ||
              state.matchedLocation == '/signup')) {
        return '/dashboard';
      }

      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
      GoRoute(
          path: '/onboarding', builder: (_, __) => const OnboardingScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/signup', builder: (_, __) => const SignupScreen()),
      GoRoute(path: '/otp', builder: (_, __) => const OtpScreen()),
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
              path: '/dashboard', pageBuilder: _fade(const DashboardScreen())),
          GoRoute(path: '/folders', pageBuilder: _fade(const FoldersScreen())),
          GoRoute(
              path: '/transactions',
              pageBuilder: _fade(const TransactionsScreen())),
          GoRoute(path: '/goals', pageBuilder: _fade(const WishlistScreen())),
          GoRoute(
              path: '/analytics', pageBuilder: _fade(const AnalyticsScreen())),
          GoRoute(path: '/coach', pageBuilder: _fade(const AiCoachScreen())),
          GoRoute(path: '/profile', pageBuilder: _fade(const ProfileScreen())),
          GoRoute(
              path: '/settings', pageBuilder: _fade(const SettingsScreen())),
        ],
      ),
    ],
  );
});

Page<dynamic> Function(BuildContext, GoRouterState) _fade(Widget child) {
  return (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: child,
        transitionsBuilder: (_, anim, __, c) =>
            FadeTransition(opacity: anim, child: c),
      );
}
