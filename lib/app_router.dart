import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'services/auth_service.dart';
import 'screens/login_screen.dart';
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
      final isBranchOverviewRoute = location.startsWith('/branch/');
      final isAuthCallback = location == '/auth/callback';

      // Don't redirect auth callback - let it handle the OAuth response
      if (isAuthCallback) {
        return null;
      }

      // If user is authenticated and trying to access login, redirect to home
      if (isAuthenticated && isLoginRoute) {
        return '/home';
      }

      // If user is not authenticated and trying to access protected routes, redirect to login
      if (!isAuthenticated &&
          (isHomeRoute || isRepoRoute || isBranchOverviewRoute)) {
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
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/auth/callback',
        name: 'auth-callback',
        builder: (context, state) {
          // Handle OAuth callback - Supabase will automatically process the session
          // This screen will show a loading indicator while processing
          return const _AuthCallbackScreen();
        },
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
        path: '/branch/:owner/:name/:branch',
        name: 'branch-overview',
        builder: (context, state) {
          final owner = state.pathParameters['owner'] ?? '';
          final name = state.pathParameters['name'] ?? '';
          final branch = state.pathParameters['branch'] ?? '';
          if (owner.isEmpty || name.isEmpty || branch.isEmpty) {
            return const Scaffold(
              body: Center(child: Text('Invalid branch path')),
            );
          }
          return BranchOverviewScreen(
            owner: owner,
            repoName: name,
            branchName: branch,
          );
        },
      ),
    ],
  );
}

/// Screen that handles OAuth callback
/// Supabase automatically processes the session from URL parameters
class _AuthCallbackScreen extends StatefulWidget {
  const _AuthCallbackScreen();

  @override
  State<_AuthCallbackScreen> createState() => _AuthCallbackScreenState();
}

class _AuthCallbackScreenState extends State<_AuthCallbackScreen> {
  @override
  void initState() {
    super.initState();
    _handleCallback();
  }

  Future<void> _handleCallback() async {
    try {
      // Supabase automatically processes the session from URL parameters
      // Wait for the session to be established
      await Future.delayed(const Duration(milliseconds: 1000));

      // Check multiple times to ensure session is established
      bool isAuthenticated = false;
      for (int i = 0; i < 5; i++) {
        isAuthenticated = Supabase.instance.client.auth.currentSession != null;
        if (isAuthenticated) break;
        await Future.delayed(const Duration(milliseconds: 500));
      }

      if (mounted) {
        if (isAuthenticated) {
          // Redirect to home after successful authentication
          context.go('/home');
        } else {
          // Redirect to login if authentication failed
          context.go('/login');
        }
      }
    } catch (e) {
      // If there's an error, redirect to login
      if (mounted) {
        context.go('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
