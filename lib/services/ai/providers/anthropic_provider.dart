import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../models/ai_message.dart';
import 'ai_provider.dart';

/// Anthropic (Claude) API provider implementation
class AnthropicProvider implements AIProvider {
  final String? apiKey;
  static const String _baseUrl = 'https://api.anthropic.com/v1';

  AnthropicProvider({this.apiKey});

  @override
  String get name => 'Anthropic';

  @override
  bool get isConfigured => apiKey != null && apiKey!.isNotEmpty;

  @override
  Future<AIResponse> chatCompletion({
    required List<AIMessage> messages,
    String? model,
    double? temperature,
    int? maxTokens,
  }) async {
    if (!isConfigured) {
      throw Exception('Anthropic API key is not configured');
    }

    // Convert messages format for Anthropic API
    final systemMessage = messages.firstWhere(
      (m) => m.role == 'system',
      orElse: () => const AIMessage(role: 'user', content: ''),
    );
    final conversationMessages = messages
        .where((m) => m.role != 'system')
        .map(
          (m) => {
            'role': m.role == 'assistant' ? 'assistant' : 'user',
            'content': m.content,
          },
        )
        .toList();

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/messages'),
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': apiKey!,
          'anthropic-version': '2023-06-01',
        },
        body: jsonEncode({
          'model': model ?? 'claude-3-5-sonnet-20241022',
          'max_tokens': maxTokens ?? 1024,
          if (systemMessage.content.isNotEmpty) 'system': systemMessage.content,
          'messages': conversationMessages,
          if (temperature != null) 'temperature': temperature,
        }),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final content = json['content']?[0]?['text'] as String? ?? '';
        final modelName = json['model'] as String?;

        return AIResponse(content: content, model: modelName, metadata: json);
      } else {
        throw Exception(
          'Anthropic API error: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Error calling Anthropic API: $e');
    }
  }

  @override
  Stream<String> streamChatCompletion({
    required List<AIMessage> messages,
    String? model,
    double? temperature,
    int? maxTokens,
  }) async* {
    if (!isConfigured) {
      throw Exception('Anthropic API key is not configured');
    }

    // Convert messages format for Anthropic API
    final systemMessage = messages.firstWhere(
      (m) => m.role == 'system',
      orElse: () => const AIMessage(role: 'user', content: ''),
    );
    final conversationMessages = messages
        .where((m) => m.role != 'system')
        .map(
          (m) => {
            'role': m.role == 'assistant' ? 'assistant' : 'user',
            'content': m.content,
          },
        )
        .toList();

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/messages'),
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': apiKey!,
          'anthropic-version': '2023-06-01',
        },
        body: jsonEncode({
          'model': model ?? 'claude-3-5-sonnet-20241022',
          'max_tokens': maxTokens ?? 1024,
          if (systemMessage.content.isNotEmpty) 'system': systemMessage.content,
          'messages': conversationMessages,
          'stream': true,
          if (temperature != null) 'temperature': temperature,
        }),
      );

      if (response.statusCode == 200) {
        final lines = response.body.split('\n');
        for (final line in lines) {
          if (line.startsWith('data: ') && line != 'data: [DONE]') {
            try {
              final json =
                  jsonDecode(line.substring(6)) as Map<String, dynamic>;
              if (json['type'] == 'content_block_delta') {
                final text = json['delta']?['text'] as String?;
                if (text != null && text.isNotEmpty) {
                  yield text;
                }
              }
            } catch (_) {
              // Skip invalid JSON lines
            }
          }
        }
      } else {
        throw Exception(
          'Anthropic API error: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Error calling Anthropic API: $e');
    }
  }

  @override
  Future<bool> testConnection() async {
    if (!isConfigured) {
      return false;
    }

    try {
      // Use cheapest model (claude-3-haiku) with minimal tokens for testing
      final response = await http.post(
        Uri.parse('$_baseUrl/messages'),
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': apiKey!,
          'anthropic-version': '2023-06-01',
        },
        body: jsonEncode({
          'model': 'claude-3-haiku-20240307', // Cheapest model
          'max_tokens': 1, // Minimum tokens
          'messages': [
            {'role': 'user', 'content': 'OK'},
          ],
        }),
      );

      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
