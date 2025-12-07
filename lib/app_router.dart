import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'services/auth_service.dart';
import 'screens/home_screen.dart';
import 'screens/logged_in_screen.dart';
import 'screens/repository_branches_screen.dart';
import 'screens/branch_comparison_screen.dart';

/// Router configuration for the app
class AppRouter {
  static final AuthService _authService = AuthService();
  static final ValueNotifier<bool> _authStateNotifier = ValueNotifier<bool>(
    _authService.isAuthenticated,
  );
  static bool _initialized = false;

  /// Initialize the router and set up auth state listener
  static void _initialize() {
    if (_initialized) return;
    _initialized = true;

    // Listen to auth state changes and update the notifier
    _authService.authStateChanges.listen((authState) {
      final isAuthenticated = _authService.isAuthenticated;
      if (_authStateNotifier.value != isAuthenticated) {
        _authStateNotifier.value = isAuthenticated;
      }
    });
  }

  /// Get the router instance
  static GoRouter get router {
    _initialize();
    return _router;
  }

  static final GoRouter _router = GoRouter(
    initialLocation: '/',
    refreshListenable: _authStateNotifier,
    redirect: (BuildContext context, GoRouterState state) {
      final isAuthenticated = _authService.isAuthenticated;
      final location = state.uri.path;
      final isLoginRoute = location == '/login' || location == '/';
      final isHomeRoute = location == '/home';
      final isRepoRoute = location.startsWith('/repo/');
      final isCompareRoute = location.startsWith('/compare/');

      // If user is authenticated and trying to access login, redirect to home
      if (isAuthenticated && isLoginRoute) {
        return '/home';
      }

      // If user is not authenticated and trying to access protected routes, redirect to login
      if (!isAuthenticated && (isHomeRoute || isRepoRoute || isCompareRoute)) {
        return '/login';
      }

      // If at root and not authenticated, go to login
      if (!isAuthenticated && location == '/') {
        return '/login';
      }

      // If at root and authenticated, go to home
      if (isAuthenticated && location == '/') {
        return '/home';
      }

      return null; // No redirect needed
    },
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const LoggedInScreen(),
      ),
      GoRoute(
        path: '/repo/:owner/:name',
        name: 'repository-branches',
        builder: (context, state) {
          final owner = state.pathParameters['owner'] ?? '';
          final name = state.pathParameters['name'] ?? '';
          if (owner.isEmpty || name.isEmpty) {
            return const Scaffold(
              body: Center(child: Text('Invalid repository path')),
            );
          }
          return RepositoryBranchesScreen(owner: owner, repoName: name);
        },
      ),
      GoRoute(
        path: '/compare/:owner/:name/:branch',
        name: 'branch-comparison',
        builder: (context, state) {
          final owner = state.pathParameters['owner'] ?? '';
          final name = state.pathParameters['name'] ?? '';
          final branch = state.pathParameters['branch'] ?? '';
          if (owner.isEmpty || name.isEmpty || branch.isEmpty) {
            return const Scaffold(
              body: Center(child: Text('Invalid comparison path')),
            );
          }
          return BranchComparisonScreen(
            owner: owner,
            repoName: name,
            branchName: branch,
          );
        },
      ),
    ],
  );
}
