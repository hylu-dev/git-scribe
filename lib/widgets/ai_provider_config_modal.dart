import 'package:flutter/material.dart';
import '../services/ai_service.dart';

/// Modal dialog for configuring AI provider and API key
class AIProviderConfigModal extends StatefulWidget {
  const AIProviderConfigModal({super.key});

  static Future<void> show(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (context) => const AIProviderConfigModal(),
    );
  }

  @override
  State<AIProviderConfigModal> createState() => _AIProviderConfigModalState();
}

class _AIProviderConfigModalState extends State<AIProviderConfigModal> {
  final _aiService = AIService();
  final _apiKeyController = TextEditingController();
  final _ollamaBaseUrlController = TextEditingController();
  AIProviderType? _selectedProvider;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _selectedProvider = _aiService.providerType;
    _apiKeyController.text = _aiService.apiKey ?? '';
    _ollamaBaseUrlController.text =
        _aiService.ollamaBaseUrl ?? 'http://localhost:11434';
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
        return 'Gemini models (gemini-2.0-flash-exp, etc.)';
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
      _aiService.setProvider(
        _selectedProvider!,
        apiKey: _apiKeyController.text.trim().isEmpty
            ? null
            : _apiKeyController.text.trim(),
        baseUrl: _selectedProvider == AIProviderType.ollama
            ? (_ollamaBaseUrlController.text.trim().isEmpty
                  ? null
                  : _ollamaBaseUrlController.text.trim())
            : null,
      );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${_getProviderName(_selectedProvider!)} configured successfully',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to configure provider: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Configure AI Provider'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Provider selection
            const Text(
              'Select AI Provider',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            ...AIProviderType.values.map((provider) {
              return RadioListTile<AIProviderType>(
                title: Text(_getProviderName(provider)),
                subtitle: Text(
                  _getProviderDescription(provider),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                value: provider,
                groupValue: _selectedProvider,
                onChanged: (value) {
                  setState(() {
                    _selectedProvider = value;
                    _errorMessage = null;
                  });
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
                              icon: const Icon(Icons.visibility_off),
                              onPressed: () {
                                // Toggle visibility would require a separate state
                              },
                            )
                          : null,
                    ),
                    obscureText: true,
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
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _saveConfiguration,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Save'),
        ),
      ],
    );
  }
}
