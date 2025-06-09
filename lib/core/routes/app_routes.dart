import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:marunthon_app/features/auth/presentation/login_page.dart';
import 'package:marunthon_app/features/home/home_page.dart';
import 'package:marunthon_app/features/runs/run_detail_page.dart';
import 'package:marunthon_app/features/user/user_profile/setup/screens/user_profile_setup_screen.dart';
import 'package:marunthon_app/features/user/user_profile/setup/screens/user_setup_complete_screen.dart';
import 'package:marunthon_app/features/user/user_profile/presentation/user_profile_screen.dart';
import 'package:marunthon_app/features/runs/models/run_model.dart';
import 'package:marunthon_app/features/settings/screens/settings_screen.dart';

class AppRoutes {
  final GoRouter router = GoRouter(
    routes: [
      GoRoute(path: '/', builder: (context, state) => const HomePage()),
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(
        path: '/profile-setup',
        builder:
            (context, state) => const UserProfileSetupScreen(isEditMode: false),
      ),
      GoRoute(
        path: '/profile-edit',
        builder:
            (context, state) => const UserProfileSetupScreen(isEditMode: true),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const UserProfileScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/setup-complete',
        builder: (context, state) {
          final userName = state.uri.queryParameters['name'] ?? 'User';
          return UserSetupCompleteScreen(
            userName: userName,
            onContinue: () => context.go('/'),
          );
        },
      ),
      GoRoute(
        path: '/run-detail',
        builder: (context, state) {
          final run = state.extra as RunModel;
          return RunDetailPage(run: run);
        },
      ),
    ],
    redirect: (context, state) {
      return null;
    },
    errorBuilder:
        (context, state) =>
            Scaffold(body: Center(child: Text('Error: ${state.error}'))),
  );
}
