import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'services/auth_service.dart';
import 'screens/home_screen.dart';
import 'screens/logged_in_screen.dart';

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
      final isLoginRoute =
          state.matchedLocation == '/login' || state.matchedLocation == '/';
      final isHomeRoute = state.matchedLocation == '/home';

      // If user is authenticated and trying to access login, redirect to home
      if (isAuthenticated && isLoginRoute) {
        return '/home';
      }

      // If user is not authenticated and trying to access home, redirect to login
      if (!isAuthenticated && isHomeRoute) {
        return '/login';
      }

      // If at root and not authenticated, go to login
      if (!isAuthenticated && state.matchedLocation == '/') {
        return '/login';
      }

      // If at root and authenticated, go to home
      if (isAuthenticated && state.matchedLocation == '/') {
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
    ],
  );
}
