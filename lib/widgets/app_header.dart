import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../widgets/theme_selector.dart';
import '../widgets/breadcrumbs.dart';

/// Shared header component for authenticated screens
class AppHeader extends StatelessWidget {
  final List<BreadcrumbItem> breadcrumbs;
  final Widget? trailingAction;

  const AppHeader({super.key, required this.breadcrumbs, this.trailingAction});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final displayName = authService.userDisplayName ?? 'User';
    final avatarUrl = authService.userAvatarUrl;
    final email = authService.userEmail;

    return Column(
      children: [
        // Top bar with app title, user, and actions
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              // App title
              Text(
                'GitScribe',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              // User info
              Row(
                children: [
                  if (avatarUrl != null)
                    CircleAvatar(
                      radius: 16,
                      backgroundImage: NetworkImage(avatarUrl),
                    )
                  else
                    CircleAvatar(
                      radius: 16,
                      child: Text(
                        displayName[0].toUpperCase(),
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        displayName,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (email != null)
                        Text(
                          email,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                    ],
                  ),
                ],
              ),
              const SizedBox(width: 16),
              // Theme selector
              IconButton(
                icon: const Icon(Icons.palette),
                onPressed: () => ThemeSelector.show(context),
                tooltip: 'Select Theme',
              ),
              // Logout
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () async {
                  await authService.signOut();
                },
                tooltip: 'Logout',
              ),
              // Trailing action (e.g., refresh button)
              if (trailingAction != null) trailingAction!,
            ],
          ),
        ),
        const Divider(height: 1),
        // Breadcrumbs
        Breadcrumbs(items: breadcrumbs),
        const Divider(height: 1),
      ],
    );
  }
}
