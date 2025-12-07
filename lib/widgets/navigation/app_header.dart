import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/ai_service.dart';
import '../modals/theme_selector.dart';
import 'breadcrumbs.dart';
import '../modals/ai_provider_config_modal.dart';

/// Shared header component for authenticated screens
class AppHeader extends StatefulWidget {
  final List<BreadcrumbItem> breadcrumbs;
  final Widget? trailingAction;

  const AppHeader({super.key, required this.breadcrumbs, this.trailingAction});

  @override
  State<AppHeader> createState() => _AppHeaderState();
}

class _AppHeaderState extends State<AppHeader> {
  final _aiService = AIService();

  String _getProviderName(AIProviderType? type) {
    if (type == null) return '';
    switch (type) {
      case AIProviderType.openai:
        return 'OpenAI';
      case AIProviderType.anthropic:
        return 'Anthropic';
      case AIProviderType.gemini:
        return 'Gemini';
      case AIProviderType.ollama:
        return 'Ollama';
    }
  }

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
              if (widget.trailingAction != null) widget.trailingAction!,
            ],
          ),
        ),
        const Divider(height: 1),
        // AI Provider Status Section
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: Row(
            children: [
              Icon(
                _aiService.isConfigured ? Icons.check_circle : Icons.warning,
                size: 20,
                color: _aiService.isConfigured
                    ? Colors.green
                    : Theme.of(context).colorScheme.error,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _aiService.isConfigured
                      ? 'AI Provider: ${_getProviderName(_aiService.providerType)} (Ready)'
                      : 'AI Provider: Not configured',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              TextButton.icon(
                onPressed: () async {
                  await AIProviderConfigModal.show(context);
                  if (mounted) {
                    setState(() {}); // Refresh to show updated status
                  }
                },
                icon: const Icon(Icons.settings, size: 18),
                label: Text(
                  _aiService.isConfigured ? 'Update' : 'Configure',
                  style: const TextStyle(fontSize: 12),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
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
