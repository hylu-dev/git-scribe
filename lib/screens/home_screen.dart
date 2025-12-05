import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../widgets/github_login_button.dart';

/// Home screen that shows login button when not authenticated
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('GitScribe', style: Theme.of(context).textTheme.headlineLarge),
            const SizedBox(height: 24),
            GitHubLoginButton(
              onPressed: () async {
                final authService = AuthService();
                try {
                  await authService.signInWithGitHub();
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
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
