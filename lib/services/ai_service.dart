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

  /// Set the provider and its API key/configuration
  ///
  /// For OpenAI, Anthropic, and Gemini: provide [apiKey]
  /// For Ollama: optionally provide [baseUrl] (defaults to http://localhost:11434)
  ///             and optionally provide [apiKey] if your Ollama instance requires it
  void setProvider(
    AIProviderType type, {
    String? apiKey,
    String? baseUrl, // Only used for Ollama
  }) {
    _providerType = type;
    _apiKey = apiKey;
    if (type == AIProviderType.ollama) {
      _ollamaBaseUrl = baseUrl;
    }
    _provider = _createProvider();
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
}
