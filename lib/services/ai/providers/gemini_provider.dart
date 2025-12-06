import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../models/ai_message.dart';
import '../ai_provider.dart';

/// Google Gemini API provider implementation
class GeminiProvider implements AIProvider {
  final String? apiKey;
  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta';

  GeminiProvider({this.apiKey});

  @override
  String get name => 'Gemini';

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
      throw Exception('Gemini API key is not configured');
    }

    // Convert messages format for Gemini API
    final contents = messages
        .where((m) => m.role != 'system')
        .map(
          (m) => {
            'role': m.role == 'assistant' ? 'model' : 'user',
            'parts': [
              {'text': m.content},
            ],
          },
        )
        .toList();

    // Extract system instruction if present
    final systemInstruction = messages
        .where((m) => m.role == 'system')
        .map((m) => m.content)
        .join('\n');

    try {
      final modelName = model ?? 'gemini-2.0-flash-exp';
      final url = Uri.parse(
        '$_baseUrl/models/$modelName:generateContent?key=$apiKey',
      );

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': contents,
          if (systemInstruction.isNotEmpty)
            'systemInstruction': {
              'parts': [
                {'text': systemInstruction},
              ],
            },
          'generationConfig': {
            if (temperature != null) 'temperature': temperature,
            if (maxTokens != null) 'maxOutputTokens': maxTokens,
          },
        }),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final content =
            json['candidates']?[0]?['content']?['parts']?[0]?['text']
                as String? ??
            '';

        return AIResponse(content: content, model: modelName, metadata: json);
      } else {
        throw Exception(
          'Gemini API error: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Error calling Gemini API: $e');
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
      throw Exception('Gemini API key is not configured');
    }

    // Convert messages format for Gemini API
    final contents = messages
        .where((m) => m.role != 'system')
        .map(
          (m) => {
            'role': m.role == 'assistant' ? 'model' : 'user',
            'parts': [
              {'text': m.content},
            ],
          },
        )
        .toList();

    // Extract system instruction if present
    final systemInstruction = messages
        .where((m) => m.role == 'system')
        .map((m) => m.content)
        .join('\n');

    try {
      final modelName = model ?? 'gemini-2.0-flash-exp';
      final url = Uri.parse(
        '$_baseUrl/models/$modelName:streamGenerateContent?key=$apiKey',
      );

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': contents,
          if (systemInstruction.isNotEmpty)
            'systemInstruction': {
              'parts': [
                {'text': systemInstruction},
              ],
            },
          'generationConfig': {
            if (temperature != null) 'temperature': temperature,
            if (maxTokens != null) 'maxOutputTokens': maxTokens,
          },
        }),
      );

      if (response.statusCode == 200) {
        final lines = response.body.split('\n');
        for (final line in lines) {
          if (line.trim().isNotEmpty) {
            try {
              final json = jsonDecode(line) as Map<String, dynamic>;
              final candidates = json['candidates'] as List?;
              if (candidates != null && candidates.isNotEmpty) {
                final content =
                    candidates[0]?['content']?['parts']?[0]?['text'] as String?;
                if (content != null && content.isNotEmpty) {
                  yield content;
                }
              }
            } catch (_) {
              // Skip invalid JSON lines
            }
          }
        }
      } else {
        throw Exception(
          'Gemini API error: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Error calling Gemini API: $e');
    }
  }
}
