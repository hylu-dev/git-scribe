# AI Service

A simple AI service that uses Google Gemini for AI-powered features.

## Configuration

The Gemini API key is configured via environment variables:

```bash
# In your .env file or build command
GEMINI_API_KEY=your-gemini-api-key
```

Or via dart-define:
```bash
flutter run --dart-define=GEMINI_API_KEY=your-key
```

## Usage

### Send Messages

```dart
final aiService = AIService();

final messages = [
  AIMessage(role: 'system', content: 'You are a helpful assistant.'),
  AIMessage(role: 'user', content: 'Hello, how are you?'),
];

// Non-streaming
final response = await aiService.chatCompletion(messages: messages);
print(response.content);

// Streaming
aiService.streamChatCompletion(messages: messages).listen((chunk) {
  print(chunk);
});
```

### Check Service Status

```dart
// Check if Gemini is configured
if (aiService.isConfigured) {
  // Service is ready to use
}
```

## Architecture

- **`AIService`** - Singleton service that wraps Gemini provider
- **`GeminiProvider`** - Implementation for Google Gemini API
- **`AIMessage`** - Message model for conversations
- **`AIResponse`** - Response model from the API
