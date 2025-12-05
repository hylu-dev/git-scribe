import 'package:flutter/material.dart';
import '../services/auth_service.dart';

/// Screen shown after successful authentication
class LoggedInScreen extends StatelessWidget {
  const LoggedInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final displayName = authService.userDisplayName ?? 'User';
    final avatarUrl = authService.userAvatarUrl;
    final email = authService.userEmail;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('GitScribe'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authService.signOut();
            },
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (avatarUrl != null)
              CircleAvatar(radius: 50, backgroundImage: NetworkImage(avatarUrl))
            else
              CircleAvatar(
                radius: 50,
                child: Text(
                  displayName[0].toUpperCase(),
                  style: const TextStyle(fontSize: 40),
                ),
              ),
            const SizedBox(height: 24),
            Text(
              displayName,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            if (email != null) ...[
              const SizedBox(height: 8),
              Text(
                email,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
            ],
            const SizedBox(height: 32),
            Text(
              'Welcome to GitScribe!',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'You are successfully logged in.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
