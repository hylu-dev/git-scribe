/// Represents a message in an AI conversation
class AIMessage {
  final String role; // 'user', 'assistant', 'system'
  final String content;

  const AIMessage({
    required this.role,
    required this.content,
  });

  Map<String, dynamic> toJson() => {
        'role': role,
        'content': content,
      };

  factory AIMessage.fromJson(Map<String, dynamic> json) => AIMessage(
        role: json['role'] as String,
        content: json['content'] as String,
      );
}

/// Represents a response from an AI provider
class AIResponse {
  final String content;
  final String? model;
  final Map<String, dynamic>? metadata;

  const AIResponse({
    required this.content,
    this.model,
    this.metadata,
  });
}

