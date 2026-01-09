import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/ai_message.dart';
import 'ai/ai_provider.dart';
import 'ai/providers/openai_provider.dart';
import 'ai/providers/anthropic_provider.dart';
import 'ai/providers/gemini_provider.dart';
import 'ai/providers/ollama_provider.dart';

/// Supported AI providers
enum AIProviderType { openai, anthropic, gemini, ollama }

/// Service for managing a single AI provider and its API key
class AIService {
  static final AIService _instance = AIService._internal();
  factory AIService() => _instance;
  AIService._internal();

  // Current provider configuration
  AIProviderType? _providerType;
  String? _apiKey;
  String? _ollamaBaseUrl; // Only used for Ollama
  AIProvider? _provider;
  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  /// Get storage key for a provider's API key
  String _getApiKeyKey(AIProviderType type) => 'ai_provider_${type.name}_api_key';

  /// Get storage key for a provider's base URL (Ollama only)
  String _getBaseUrlKey() => 'ai_provider_ollama_base_url';

  /// Get storage key for the selected provider
  String _getSelectedProviderKey() => 'ai_provider_selected';

  /// Get saved API key for a specific provider
  Future<String?> getSavedApiKey(AIProviderType type) async {
    return await _storage.read(key: _getApiKeyKey(type));
  }

  /// Get saved base URL for Ollama
  Future<String?> getSavedBaseUrl() async {
    return await _storage.read(key: _getBaseUrlKey());
  }

  /// Get saved selected provider
  Future<AIProviderType?> getSavedProvider() async {
    final providerName = await _storage.read(key: _getSelectedProviderKey());
    if (providerName == null) return null;
    try {
      return AIProviderType.values.firstWhere(
        (e) => e.name == providerName,
      );
    } catch (e) {
      return null;
    }
  }

  /// Set the provider and its API key/configuration
  ///
  /// For OpenAI, Anthropic, and Gemini: provide [apiKey]
  /// For Ollama: optionally provide [baseUrl] (defaults to http://localhost:11434)
  ///             and optionally provide [apiKey] if your Ollama instance requires it
  Future<void> setProvider(
    AIProviderType type, {
    String? apiKey,
    String? baseUrl, // Only used for Ollama
    bool saveToStorage = true, // Whether to persist to storage
  }) async {
    _providerType = type;
    _apiKey = apiKey;
    if (type == AIProviderType.ollama) {
      _ollamaBaseUrl = baseUrl;
    }
    _provider = _createProvider();

    // Save to persistent storage
    if (saveToStorage) {
      // Save selected provider
      await _storage.write(key: _getSelectedProviderKey(), value: type.name);
      
      // Save API key for this provider
      if (apiKey != null && apiKey.isNotEmpty) {
        await _storage.write(key: _getApiKeyKey(type), value: apiKey);
      } else {
        // Remove if empty
        await _storage.delete(key: _getApiKeyKey(type));
      }

      // Save Ollama base URL if provided
      if (type == AIProviderType.ollama) {
        if (baseUrl != null && baseUrl.isNotEmpty) {
          await _storage.write(key: _getBaseUrlKey(), value: baseUrl);
        } else {
          await _storage.delete(key: _getBaseUrlKey());
        }
      }
    }
  }

  /// Load saved provider configuration from storage
  Future<void> loadSavedConfiguration() async {
    // Load saved provider
    final savedProvider = await getSavedProvider();
    if (savedProvider == null) return;

    // Load saved API key for this provider
    final savedApiKey = await getSavedApiKey(savedProvider);
    
    // Load saved base URL if Ollama
    String? savedBaseUrl;
    if (savedProvider == AIProviderType.ollama) {
      savedBaseUrl = await getSavedBaseUrl();
    }

    // Set provider with saved values (don't save again to avoid recursion)
    await setProvider(
      savedProvider,
      apiKey: savedApiKey,
      baseUrl: savedBaseUrl,
      saveToStorage: false,
    );
  }

  /// Clear all saved API keys and configuration from storage
  Future<void> clearSavedConfiguration() async {
    // Clear all provider API keys
    for (final provider in AIProviderType.values) {
      await _storage.delete(key: _getApiKeyKey(provider));
    }
    
    // Clear Ollama base URL
    await _storage.delete(key: _getBaseUrlKey());
    
    // Clear selected provider
    await _storage.delete(key: _getSelectedProviderKey());
    
    // Clear current in-memory configuration
    _providerType = null;
    _apiKey = null;
    _ollamaBaseUrl = null;
    _provider = null;
  }

  /// Get the current provider
  AIProvider? get currentProvider => _provider;

  /// Get the current provider type
  AIProviderType? get providerType => _providerType;

  /// Get the current API key (null if not set)
  String? get apiKey => _apiKey;

  /// Get the Ollama base URL (only relevant for Ollama provider)
  String? get ollamaBaseUrl => _ollamaBaseUrl;

  /// Check if the current provider is configured
  bool get isConfigured {
    if (_provider == null) return false;
    return _provider!.isConfigured;
  }

  /// Create a provider instance based on current configuration
  AIProvider _createProvider() {
    switch (_providerType) {
      case AIProviderType.openai:
        return OpenAIProvider(apiKey: _apiKey);
      case AIProviderType.anthropic:
        return AnthropicProvider(apiKey: _apiKey);
      case AIProviderType.gemini:
        return GeminiProvider(apiKey: _apiKey);
      case AIProviderType.ollama:
        return OllamaProvider(baseUrl: _ollamaBaseUrl, apiKey: _apiKey);
      case null:
        throw Exception('No provider type set');
    }
  }

  /// Send a chat completion using the current provider
  Future<AIResponse> chatCompletion({
    required List<AIMessage> messages,
    String? model,
    double? temperature,
    int? maxTokens,
  }) async {
    if (_provider == null) {
      throw Exception('No AI provider selected. Call setProvider() first.');
    }

    if (!_provider!.isConfigured) {
      throw Exception(
        '${_provider!.name} is not configured. Please set the API key.',
      );
    }

    return _provider!.chatCompletion(
      messages: messages,
      model: model,
      temperature: temperature,
      maxTokens: maxTokens,
    );
  }

  /// Stream a chat completion using the current provider
  Stream<String> streamChatCompletion({
    required List<AIMessage> messages,
    String? model,
    double? temperature,
    int? maxTokens,
  }) {
    if (_provider == null) {
      throw Exception('No AI provider selected. Call setProvider() first.');
    }

    if (!_provider!.isConfigured) {
      throw Exception(
        '${_provider!.name} is not configured. Please set the API key.',
      );
    }

    return _provider!.streamChatCompletion(
      messages: messages,
      model: model,
      temperature: temperature,
      maxTokens: maxTokens,
    );
  }

  /// Test the current provider connection and configuration
  /// Returns true if the provider is working correctly
  Future<bool> testProvider() async {
    if (_provider == null) {
      throw Exception('No AI provider selected. Call setProvider() first.');
    }

    if (!_provider!.isConfigured) {
      return false;
    }

    return _provider!.testConnection();
  }
}
