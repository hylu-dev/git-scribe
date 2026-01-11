import '../../models/ai_message.dart';
import '../../utils/env.dart';
import 'providers/gemini_provider.dart';

/// Service for AI chat completions using Gemini
class AIService {
  static final AIService _instance = AIService._internal();
  factory AIService() => _instance;
  AIService._internal();

  GeminiProvider? _provider;

  /// Initialize the Gemini provider with API key from environment
  void _ensureInitialized() {
    if (_provider == null) {
      if (!Env.hasGeminiApiKey) {
        throw Exception(
          'Gemini API key is not configured. '
          'Please set GEMINI_API_KEY in your environment.',
        );
      }
      _provider = GeminiProvider(apiKey: Env.geminiApiKey);
    }
  }

  /// Check if the AI service is configured
  bool get isConfigured => Env.hasGeminiApiKey;

  /// Send a chat completion request
  Future<AIResponse> chatCompletion({
    required List<AIMessage> messages,
    String? model,
    double? temperature,
    int? maxTokens,
  }) async {
    _ensureInitialized();
    return _provider!.chatCompletion(
      messages: messages,
      model: model,
      temperature: temperature,
      maxTokens: maxTokens,
    );
  }

  /// Stream a chat completion (for real-time responses)
  Stream<String> streamChatCompletion({
    required List<AIMessage> messages,
    String? model,
    double? temperature,
    int? maxTokens,
  }) {
    _ensureInitialized();
    return _provider!.streamChatCompletion(
      messages: messages,
      model: model,
      temperature: temperature,
      maxTokens: maxTokens,
    );
  }

  /// Test the provider connection
  Future<bool> testConnection() async {
    _ensureInitialized();
    return _provider!.testConnection();
  }
}
