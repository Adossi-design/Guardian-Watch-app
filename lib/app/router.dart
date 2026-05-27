import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/presentation/bloc/auth_provider.dart';
import '../features/auth/presentation/pages/sign_in_page.dart';
import '../features/auth/presentation/pages/register_page.dart';
import '../features/auth/presentation/pages/mfa_page.dart';
import '../features/dashboard_primary/presentation/pages/primary_dashboard_page.dart';
import '../features/dashboard_monitor/presentation/pages/monitor_dashboard_page.dart';
import '../features/emergency/presentation/pages/emergency_active_page.dart';
import '../features/emergency/presentation/pages/emergency_countdown_page.dart';
import '../features/geofencing/presentation/pages/geofence_zones_page.dart';
import '../features/geofencing/presentation/pages/live_tracking_page.dart';
import '../features/health_monitoring/presentation/pages/health_dashboard_page.dart';
import '../features/onboarding/presentation/pages/onboarding_page.dart';
import '../features/multi_device/presentation/pages/accept_invite_page.dart';
import '../features/multi_device/presentation/pages/invite_page.dart';
import '../features/settings/presentation/pages/settings_page.dart';
import '../features/voice_ai/presentation/pages/voice_assistant_page.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authNotifierProvider);

  return GoRouter(
    initialLocation: '/sign-in',
    redirect: (context, state) {
      final isAuth = authState.maybeWhen(
        data: (s) => s is AuthAuthenticated,
        orElse: () => false,
      );
      final isLoading = authState.isLoading;

      if (isLoading) return null;

      final onAuthRoute = state.matchedLocation.startsWith('/sign-in') ||
          state.matchedLocation.startsWith('/register') ||
          state.matchedLocation.startsWith('/mfa') ||
          state.matchedLocation.startsWith('/forgot-password') ||
          state.matchedLocation.startsWith('/onboarding');

      if (!isAuth && !onAuthRoute) return '/sign-in';
      if (isAuth && onAuthRoute) {
        final user = authState.maybeWhen(
          data: (s) => s is AuthAuthenticated ? s.user : null,
          orElse: () => null,
        );
        if (user == null) return '/sign-in';
        return switch (user.role.name) {
          'primary' => '/dashboard/primary',
          'admin' => '/dashboard/admin',
          _ => '/dashboard/monitor',
        };
      }
      return null;
    },
    routes: [
      GoRoute(path: '/sign-in', builder: (ctx, st) => const SignInPage()),
      GoRoute(path: '/register', builder: (ctx, st) => const RegisterPage()),
      GoRoute(path: '/mfa', builder: (ctx, st) => const MfaPage()),
      GoRoute(
        path: '/onboarding',
        builder: (ctx, st) => const OnboardingPage(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (ctx, st) => const _ForgotPasswordPage(),
      ),
      // Primary user dashboard
      ShellRoute(
        builder: (context, state, child) => _PrimaryShell(child: child),
        routes: [
          GoRoute(
            path: '/dashboard/primary',
            builder: (ctx, st) => const PrimaryDashboardPage(),
          ),
          GoRoute(
            path: '/health',
            builder: (ctx, st) => const HealthDashboardPage(),
          ),
          GoRoute(
            path: '/emergency/countdown',
            builder: (ctx, st) => const EmergencyCountdownPage(),
          ),
          GoRoute(
            path: '/emergency/active',
            builder: (ctx, st) => const EmergencyActivePage(),
          ),
          GoRoute(
            path: '/geofence',
            builder: (ctx, st) => const GeofenceZonesPage(),
          ),
          GoRoute(
            path: '/geofence/tracking',
            builder: (ctx, st) => const LiveTrackingPage(),
          ),
          GoRoute(
            path: '/invite',
            builder: (ctx, st) => const InvitePage(),
          ),
          GoRoute(
            path: '/settings',
            builder: (ctx, st) => const SettingsPage(),
          ),
          GoRoute(
            path: '/voice',
            builder: (ctx, st) => const VoiceAssistantPage(),
          ),
        ],
      ),
      // Monitor / caregiver dashboard
      ShellRoute(
        builder: (context, state, child) => _MonitorShell(child: child),
        routes: [
          GoRoute(
            path: '/dashboard/monitor',
            builder: (ctx, st) => const MonitorDashboardPage(),
          ),
          GoRoute(
            path: '/join',
            builder: (ctx, st) => const AcceptInvitePage(),
          ),
        ],
      ),
      // Admin dashboard (simplified scaffold for Phase 1)
      GoRoute(
        path: '/dashboard/admin',
        builder: (ctx, st) => const _AdminPlaceholderPage(),
      ),
    ],
    errorBuilder: (context, state) => _RouterErrorPage(error: state.error),
  );
});

// Shell scaffolds wire up bottom navigation per role

class _PrimaryShell extends StatelessWidget {
  const _PrimaryShell({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => child;
}

class _MonitorShell extends StatelessWidget {
  const _MonitorShell({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => child;
}

class _ForgotPasswordPage extends StatelessWidget {
  const _ForgotPasswordPage();

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Reset password')),
        body: const Center(child: Text('Password reset — Phase 1 placeholder')),
      );
}

class _AdminPlaceholderPage extends StatelessWidget {
  const _AdminPlaceholderPage();

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Admin Dashboard')),
        body: const Center(child: Text('Admin dashboard — Phase 1 placeholder')),
      );
}

class _RouterErrorPage extends StatelessWidget {
  const _RouterErrorPage({required this.error});
  final Exception? error;

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(child: Text('Navigation error: ${error?.toString() ?? "unknown"}')),
      );
}
