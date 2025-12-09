import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../widgets/common/github_login_button.dart';
import '../widgets/common/toast.dart';

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
            Text('GitScribe', style: Theme.of(context).textTheme.headlineLarge),
            const SizedBox(height: 8),
            Text(
              'AI-powered GitHub branch analysis',
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
