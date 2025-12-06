import '../../models/ai_message.dart';

/// Abstract base class for AI providers
abstract class AIProvider {
  /// Provider name identifier
  String get name;

  /// Check if the provider is configured (has API key)
  bool get isConfigured;

  /// Send a chat completion request
  /// Returns the AI response
  Future<AIResponse> chatCompletion({
    required List<AIMessage> messages,
    String? model,
    double? temperature,
    int? maxTokens,
  });

  /// Stream a chat completion (for real-time responses)
  Stream<String> streamChatCompletion({
    required List<AIMessage> messages,
    String? model,
    double? temperature,
    int? maxTokens,
  });
}

