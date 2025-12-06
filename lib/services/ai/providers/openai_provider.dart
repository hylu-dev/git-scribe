import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../models/ai_message.dart';
import '../ai_provider.dart';

/// OpenAI API provider implementation
class OpenAIProvider implements AIProvider {
  final String? apiKey;
  static const String _baseUrl = 'https://api.openai.com/v1';

  OpenAIProvider({this.apiKey});

  @override
  String get name => 'OpenAI';

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
      throw Exception('OpenAI API key is not configured');
    }

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': model ?? 'gpt-4o-mini',
          'messages': messages.map((m) => m.toJson()).toList(),
          if (temperature != null) 'temperature': temperature,
          if (maxTokens != null) 'max_tokens': maxTokens,
        }),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final content =
            json['choices']?[0]?['message']?['content'] as String? ?? '';
        final modelName = json['model'] as String?;

        return AIResponse(content: content, model: modelName, metadata: json);
      } else {
        throw Exception(
          'OpenAI API error: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Error calling OpenAI API: $e');
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
      throw Exception('OpenAI API key is not configured');
    }

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': model ?? 'gpt-4o-mini',
          'messages': messages.map((m) => m.toJson()).toList(),
          'stream': true,
          if (temperature != null) 'temperature': temperature,
          if (maxTokens != null) 'max_tokens': maxTokens,
        }),
      );

      if (response.statusCode == 200) {
        final lines = response.body.split('\n');
        for (final line in lines) {
          if (line.startsWith('data: ') && line != 'data: [DONE]') {
            try {
              final json =
                  jsonDecode(line.substring(6)) as Map<String, dynamic>;
              final delta = json['choices']?[0]?['delta'];
              final content = delta?['content'] as String?;
              if (content != null && content.isNotEmpty) {
                yield content;
              }
            } catch (_) {
              // Skip invalid JSON lines
            }
          }
        }
      } else {
        throw Exception(
          'OpenAI API error: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Error calling OpenAI API: $e');
    }
  }
}
