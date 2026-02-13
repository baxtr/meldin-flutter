class AppConfig {
  static const String apiUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://localhost:3001',
  );

  static const String wsUrl = String.fromEnvironment(
    'WS_URL',
    defaultValue: 'ws://localhost:3001',
  );

  static const List<({String id, String name})> availableModels = [
    (id: 'google/gemini-2.5-flash', name: 'Gemini 2.5'),
    (id: 'openai/gpt-5-mini', name: 'GPT-5'),
    (id: 'x-ai/grok-4-fast', name: 'xAI Grok 4'),
    (id: 'anthropic/claude-sonnet-4.5', name: 'Claude Sonnet 4.5'),
    (id: 'meta-llama/llama-4-maverick', name: 'Llama 4 Maverick'),
  ];
}
