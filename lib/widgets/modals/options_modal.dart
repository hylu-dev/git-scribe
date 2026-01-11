import 'package:flutter/material.dart';
import '../../services/auth/auth_service.dart';
import '../../services/github/github_access_guard.dart';
import '../common/toast.dart';

/// Modal dialog for app options including GitHub settings and logout
class OptionsModal extends StatefulWidget {
  const OptionsModal({super.key});

  static Future<void> show(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (context) => const OptionsModal(),
    );
  }

  @override
  State<OptionsModal> createState() => _OptionsModalState();
}

class _OptionsModalState extends State<OptionsModal> {
  final _authService = AuthService();
  bool _isRequestingOrgAccess = false;
  String? _errorMessage;

  Future<void> _handleRequestOrganizationAccess() async {
    if (!await GitHubAccessGuard.ensureAccess(context)) {
      return;
    }

    setState(() {
      _isRequestingOrgAccess = true;
      _errorMessage = null;
    });

    try {
      final granted = await _authService.requestOrganizationAccess();
      if (mounted) {
        setState(() {
          _isRequestingOrgAccess = false;
        });
        if (granted) {
          Navigator.of(context).pop();
          Toast.success(
            context,
            'Organization access updated. Please refresh your repositories.',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to request organization access: $e';
          _isRequestingOrgAccess = false;
        });
      }
    }
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      Navigator.of(context).pop();
      await _authService.signOut();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Options'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // GitHub Section
            Text(
              'GitHub',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _isRequestingOrgAccess
                  ? null
                  : _handleRequestOrganizationAccess,
              icon: _isRequestingOrgAccess
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.business),
              label: Text(
                _isRequestingOrgAccess
                    ? 'Opening GitHub...'
                    : 'Request Organization Access',
              ),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Open GitHub\'s authorization page to approve or request access to organizations',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            // Error message
            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Theme.of(context).colorScheme.onErrorContainer,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onErrorContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            // Divider before logout section
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            // Logout Section
            Text(
              'Account',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _handleLogout,
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
