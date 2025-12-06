# AI Service

A provider-agnostic AI service that supports multiple AI providers with a unified interface.

## Supported Providers

- **OpenAI** - GPT models (gpt-4o-mini, gpt-4, etc.)
- **Anthropic** - Claude models (claude-3-5-sonnet, etc.)
- **Google Gemini** - Gemini models (gemini-2.0-flash-exp, etc.)
- **Ollama** - Local models (llama3.2, etc.)

## Usage

### 1. Set Provider and API Key

The service manages a single provider at a time. Set the provider and its API key together:

```dart
final aiService = AIService();

// Set OpenAI provider with API key
aiService.setProvider(
  AIProviderType.openai,
  apiKey: 'your-openai-api-key',
);

// Set Anthropic provider with API key
aiService.setProvider(
  AIProviderType.anthropic,
  apiKey: 'your-anthropic-api-key',
);

// Set Gemini provider with API key
aiService.setProvider(
  AIProviderType.gemini,
  apiKey: 'your-gemini-api-key',
);

// Set Ollama provider (baseUrl is optional, defaults to http://localhost:11434)
aiService.setProvider(
  AIProviderType.ollama,
  baseUrl: 'http://localhost:11434', // Optional
  apiKey: null, // Optional, only if your Ollama instance requires it
);
```

### 2. Send Messages

```dart
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

### 3. Check Provider Status

```dart
// Check if current provider is configured
if (aiService.isConfigured) {
  // Provider is ready to use
}

// Get current provider type
final providerType = aiService.providerType;

// Get current API key
final apiKey = aiService.apiKey;
```

## Architecture

- **`AIProvider`** - Abstract interface for all providers
- **`AIService`** - Singleton service managing providers and API keys
- **`AIMessage`** - Message model for conversations
- **`AIResponse`** - Response model from providers

Each provider implements the `AIProvider` interface, ensuring a consistent API across all providers.

