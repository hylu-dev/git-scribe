import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/auth_service.dart';
import '../modals/theme_selector.dart';
import 'breadcrumbs.dart';
import '../modals/options_modal.dart';
import '../common/app_logo.dart';

/// Shared header component for authenticated screens
class AppHeader extends StatefulWidget {
  final List<BreadcrumbItem> breadcrumbs;

  const AppHeader({super.key, required this.breadcrumbs});

  @override
  State<AppHeader> createState() => _AppHeaderState();
}

class _AppHeaderState extends State<AppHeader> {
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
              // App logo and title (clickable to go to repository screen)
              InkWell(
                onTap: () => context.goNamed('home'),
                borderRadius: BorderRadius.circular(4),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const AppLogo(width: 42, height: 42),
                      const SizedBox(width: 8),
                      Text(
                        'GitScribe',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
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
                iconSize: 42,
                onPressed: () => ThemeSelector.show(context),
                tooltip: 'Select Theme',
                constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
              ),
              // Options (AI Provider Config & Logout)
              IconButton(
                icon: const Icon(Icons.settings),
                iconSize: 42,
                onPressed: () async {
                  await OptionsModal.show(context);
                  if (mounted) {
                    setState(() {}); // Refresh to show updated status
                  }
                },
                tooltip: 'Options',
                constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        // Breadcrumbs
        Breadcrumbs(items: widget.breadcrumbs),
        const Divider(height: 1),
      ],
    );
  }
}
