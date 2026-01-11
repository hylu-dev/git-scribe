import 'package:flutter/material.dart';
import '../../services/ai/ai_service.dart';
import '../../services/auth/auth_service.dart';
import '../../services/github/github_access_guard.dart';
import '../common/toast.dart';

/// Modal dialog for app options including AI provider config and logout
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
  final _aiService = AIService();
  final _authService = AuthService();
  final _apiKeyController = TextEditingController();
  final _ollamaBaseUrlController = TextEditingController();
  AIProviderType? _selectedProvider;
  bool _isLoading = false;
  bool _isTesting = false;
  bool _obscureApiKey = true;
  bool _isRequestingOrgAccess = false;
  String? _errorMessage;
  String? _testResult;

  @override
  void initState() {
    super.initState();
    _selectedProvider = _aiService.providerType;
    _loadProviderConfiguration();
  }

  Future<void> _loadProviderConfiguration() async {
    if (_selectedProvider != null) {
      // Load saved API key for the selected provider
      final savedApiKey = await _aiService.getSavedApiKey(_selectedProvider!);
      _apiKeyController.text = savedApiKey ?? _aiService.apiKey ?? '';

      // Load Ollama base URL if applicable
      if (_selectedProvider == AIProviderType.ollama) {
        final savedBaseUrl = await _aiService.getSavedBaseUrl();
        _ollamaBaseUrlController.text =
            savedBaseUrl ??
            _aiService.ollamaBaseUrl ??
            'http://localhost:11434';
      }
    } else {
      // Fallback to current service values
      _apiKeyController.text = _aiService.apiKey ?? '';
      _ollamaBaseUrlController.text =
          _aiService.ollamaBaseUrl ?? 'http://localhost:11434';
    }
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    _ollamaBaseUrlController.dispose();
    super.dispose();
  }

  String _getProviderName(AIProviderType type) {
    switch (type) {
      case AIProviderType.openai:
        return 'OpenAI';
      case AIProviderType.anthropic:
        return 'Anthropic (Claude)';
      case AIProviderType.gemini:
        return 'Google Gemini';
      case AIProviderType.ollama:
        return 'Ollama';
    }
  }

  String _getProviderDescription(AIProviderType type) {
    switch (type) {
      case AIProviderType.openai:
        return 'GPT models (gpt-4o-mini, gpt-4, etc.)';
      case AIProviderType.anthropic:
        return 'Claude models (claude-3-5-sonnet, etc.)';
      case AIProviderType.gemini:
        return 'Gemini models (gemini-2.5-flash-exp, etc.)';
      case AIProviderType.ollama:
        return 'Local models (llama3.2, etc.)';
    }
  }

  Future<void> _saveConfiguration() async {
    if (_selectedProvider == null) {
      setState(() {
        _errorMessage = 'Please select a provider';
      });
      return;
    }

    if (_selectedProvider != AIProviderType.ollama) {
      if (_apiKeyController.text.trim().isEmpty) {
        setState(() {
          _errorMessage = 'Please enter an API key';
        });
        return;
      }
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _aiService.setProvider(
        _selectedProvider!,
        apiKey: _apiKeyController.text.trim().isEmpty
            ? null
            : _apiKeyController.text.trim(),
        baseUrl: _selectedProvider == AIProviderType.ollama
            ? (_ollamaBaseUrlController.text.trim().isEmpty
                  ? null
                  : _ollamaBaseUrlController.text.trim())
            : null,
        saveToStorage: true,
      );

      if (mounted) {
        Navigator.of(context).pop();
        Toast.success(
          context,
          '${_getProviderName(_selectedProvider!)} configured successfully',
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to configure provider: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _testConnection() async {
    if (_selectedProvider == null) {
      setState(() {
        _testResult = 'Please select a provider first';
      });
      return;
    }

    if (_selectedProvider != AIProviderType.ollama) {
      if (_apiKeyController.text.trim().isEmpty) {
        setState(() {
          _testResult = 'Please enter an API key first';
        });
        return;
      }
    }

    setState(() {
      _isTesting = true;
      _testResult = null;
      _errorMessage = null;
    });

    try {
      // Temporarily set the provider to test it (don't save to storage during test)
      await _aiService.setProvider(
        _selectedProvider!,
        apiKey: _apiKeyController.text.trim().isEmpty
            ? null
            : _apiKeyController.text.trim(),
        baseUrl: _selectedProvider == AIProviderType.ollama
            ? (_ollamaBaseUrlController.text.trim().isEmpty
                  ? null
                  : _ollamaBaseUrlController.text.trim())
            : null,
        saveToStorage: false, // Don't save during test
      );

      final isWorking = await _aiService.testProvider();

      setState(() {
        _isTesting = false;
        if (isWorking) {
          _testResult = 'Connection test successful!';
        } else {
          _testResult =
              'Connection test failed. Please check your API key and configuration.';
        }
      });
    } catch (e) {
      setState(() {
        _isTesting = false;
        _testResult = 'Test failed: $e';
      });
    }
  }

  Future<void> _handleClearSaved() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Saved API Keys'),
        content: const Text(
          'Are you sure you want to clear all saved API keys? This will remove all stored credentials for all providers.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await _aiService.clearSavedConfiguration();

        // Clear the form fields
        _apiKeyController.clear();
        _ollamaBaseUrlController.text = 'http://localhost:11434';
        setState(() {
          _selectedProvider = null;
          _errorMessage = null;
          _testResult = null;
        });

        if (mounted) {
          Toast.success(context, 'All saved API keys have been cleared');
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _errorMessage = 'Failed to clear saved keys: $e';
          });
        }
      }
    }
  }

  Future<void> _handleRequestOrganizationAccess() async {
    if (!await GitHubAccessGuard.ensureAccess(context, mounted: mounted)) {
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
          Navigator.of(context).pop(); // Close options modal
          Toast.success(
            context,
            'Organization access updated. Please refresh your repositories.',
          );
        } else {
          // User cancelled - just reset state, don't show error
          // Modal stays open so user can try again if they want
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
      Navigator.of(context).pop(); // Close options modal
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
            // AI Provider Configuration Section
            Text(
              'AI Provider',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            // Provider selection
            // ignore: deprecated_member_use
            ...AIProviderType.values.map((provider) {
              return RadioListTile<AIProviderType>(
                title: Text(_getProviderName(provider)),
                subtitle: Text(
                  _getProviderDescription(provider),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                value: provider,
                // ignore: deprecated_member_use
                groupValue: _selectedProvider,
                // ignore: deprecated_member_use
                onChanged: (value) async {
                  setState(() {
                    _selectedProvider = value;
                    _errorMessage = null;
                  });
                  // Load saved API key for the newly selected provider
                  await _loadProviderConfiguration();
                  setState(() {}); // Update UI with loaded values
                },
              );
            }),
            const SizedBox(height: 16),
            // API Key input (for all providers except Ollama which is optional)
            if (_selectedProvider != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _selectedProvider == AIProviderType.ollama
                        ? 'API Key (Optional)'
                        : 'API Key',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _apiKeyController,
                    decoration: InputDecoration(
                      hintText: 'Enter your API key',
                      border: const OutlineInputBorder(),
                      suffixIcon: _apiKeyController.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(
                                _obscureApiKey
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureApiKey = !_obscureApiKey;
                                });
                              },
                            )
                          : null,
                    ),
                    obscureText: _obscureApiKey,
                    enabled: !_isLoading,
                    onChanged: (_) {
                      setState(() {
                        _errorMessage = null;
                      });
                    },
                  ),
                ],
              ),
            // Ollama base URL input
            if (_selectedProvider == AIProviderType.ollama) ...[
              const SizedBox(height: 16),
              const Text(
                'Base URL (Optional)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _ollamaBaseUrlController,
                decoration: const InputDecoration(
                  hintText: 'http://localhost:11434',
                  border: OutlineInputBorder(),
                ),
                enabled: !_isLoading,
                onChanged: (_) {
                  setState(() {
                    _errorMessage = null;
                  });
                },
              ),
            ],
            // Test button
            if (_selectedProvider != null) ...[
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: (_isLoading || _isTesting) ? null : _testConnection,
                icon: _isTesting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.network_check, size: 18),
                label: Text(_isTesting ? 'Testing...' : 'Test Connection'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
            ],
            // Clear saved API keys button
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: (_isLoading || _isTesting) ? null : _handleClearSaved,
              icon: const Icon(Icons.delete_outline, size: 18),
              label: const Text('Clear Saved API Keys'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                foregroundColor: Colors.red,
              ),
            ),
            // Test result message
            if (_testResult != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _testResult!.contains('successful')
                      ? Colors.green.withValues(alpha: 0.1)
                      : Theme.of(context).colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      _testResult!.contains('successful')
                          ? Icons.check_circle
                          : Icons.error_outline,
                      color: _testResult!.contains('successful')
                          ? Colors.green
                          : Theme.of(context).colorScheme.onErrorContainer,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _testResult!,
                        style: TextStyle(
                          color: _testResult!.contains('successful')
                              ? Colors.green.shade700
                              : Theme.of(context).colorScheme.onErrorContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
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
            // Divider before GitHub section
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            // GitHub Section
            Text(
              'GitHub',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: (_isLoading || _isTesting || _isRequestingOrgAccess)
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
        Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton(
                onPressed: (_isLoading || _isTesting)
                    ? null
                    : () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: (_isLoading || _isTesting)
                    ? null
                    : _saveConfiguration,
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
