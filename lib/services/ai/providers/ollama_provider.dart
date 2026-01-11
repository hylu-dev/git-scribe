import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../models/ai_message.dart';
import 'ai_provider.dart';

/// Ollama local API provider implementation
class OllamaProvider implements AIProvider {
  final String? baseUrl;
  final String? apiKey; // Optional, Ollama usually doesn't require API key

  OllamaProvider({this.baseUrl, this.apiKey});

  String get _ollamaUrl => baseUrl ?? 'http://localhost:11434';

  @override
  String get name => 'Ollama';

  @override
  bool get isConfigured => true; // Ollama doesn't require API key by default

  @override
  Future<AIResponse> chatCompletion({
    required List<AIMessage> messages,
    String? model,
    double? temperature,
    int? maxTokens,
  }) async {
    // Convert messages format for Ollama API
    final ollamaMessages = messages
        .where((m) => m.role != 'system')
        .map((m) => {'role': m.role, 'content': m.content})
        .toList();

    // Extract system message if present
    final systemMessage = messages
        .where((m) => m.role == 'system')
        .map((m) => m.content)
        .join('\n');

    try {
      final response = await http.post(
        Uri.parse('$_ollamaUrl/api/chat'),
        headers: {
          'Content-Type': 'application/json',
          if (apiKey != null) 'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': model ?? 'llama3.2',
          'messages': ollamaMessages,
          'stream': false,
          if (systemMessage.isNotEmpty) 'system': systemMessage,
          'options': {
            if (temperature != null) 'temperature': temperature,
            if (maxTokens != null) 'num_predict': maxTokens,
          },
        }),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final content = json['message']?['content'] as String? ?? '';
        final modelName = json['model'] as String?;

        return AIResponse(content: content, model: modelName, metadata: json);
      } else {
        throw Exception(
          'Ollama API error: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Error calling Ollama API: $e');
    }
  }

  @override
  Stream<String> streamChatCompletion({
    required List<AIMessage> messages,
    String? model,
    double? temperature,
    int? maxTokens,
  }) async* {
    // Convert messages format for Ollama API
    final ollamaMessages = messages
        .where((m) => m.role != 'system')
        .map((m) => {'role': m.role, 'content': m.content})
        .toList();

    // Extract system message if present
    final systemMessage = messages
        .where((m) => m.role == 'system')
        .map((m) => m.content)
        .join('\n');

    try {
      final response = await http.post(
        Uri.parse('$_ollamaUrl/api/chat'),
        headers: {
          'Content-Type': 'application/json',
          if (apiKey != null) 'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': model ?? 'llama3.2',
          'messages': ollamaMessages,
          'stream': true,
          if (systemMessage.isNotEmpty) 'system': systemMessage,
          'options': {
            if (temperature != null) 'temperature': temperature,
            if (maxTokens != null) 'num_predict': maxTokens,
          },
        }),
      );

      if (response.statusCode == 200) {
        final lines = response.body.split('\n');
        for (final line in lines) {
          if (line.trim().isNotEmpty) {
            try {
              final json = jsonDecode(line) as Map<String, dynamic>;
              final content = json['message']?['content'] as String?;
              if (content != null && content.isNotEmpty) {
                yield content;
              }
              // Check if done
              if (json['done'] == true) {
                break;
              }
            } catch (_) {
              // Skip invalid JSON lines
            }
          }
        }
      } else {
        throw Exception(
          'Ollama API error: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Error calling Ollama API: $e');
    }
  }

  @override
  Future<bool> testConnection() async {
    // Use GET /api/tags endpoint - free and doesn't require a model to be loaded
    try {
      final response = await http.get(
        Uri.parse('$_ollamaUrl/api/tags'),
        headers: {if (apiKey != null) 'Authorization': 'Bearer $apiKey'},
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        // Check if we got a valid models list
        return json['models'] != null && json['models'] is List;
      }
      return false;
    } catch (_) {
      return false;
    }
  }
}
