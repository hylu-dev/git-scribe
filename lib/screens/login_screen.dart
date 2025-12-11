import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../widgets/common/github_login_button.dart';
import '../widgets/common/toast.dart';
import '../widgets/common/app_logo.dart';

/// Login screen that shows login button when not authenticated
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const AppLogo(width: 120, height: 120),
            const SizedBox(height: 16),
            Text('GitScribe', style: Theme.of(context).textTheme.headlineLarge),
            const SizedBox(height: 8),
            Text(
              'Intelligent Insights for Every Commit',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 24),
            GitHubLoginButton(
              onPressed: () async {
                final authService = AuthService();
                try {
                  await authService.signInWithGitHub();
                } catch (e) {
                  if (context.mounted) {
                    Toast.error(context, 'Error: $e');
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
