import 'package:dio/dio.dart';
import '../models/conversation.dart';
import '../models/participant.dart';
import '../../config/app_config.dart';

class ApiClient {
  final Dio _dio;

  ApiClient({Dio? dio})
      : _dio = dio ??
            Dio(BaseOptions(
              baseUrl: AppConfig.apiUrl,
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 30),
              headers: {'Content-Type': 'application/json'},
            ));

  /// GET /api/conversations
  Future<List<Conversation>> getConversations() async {
    final response = await _dio.get<List<dynamic>>('/api/conversations');
    return response.data!
        .map((e) => Conversation.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// GET /api/conversations/:id
  Future<Conversation> getConversation(String id) async {
    final response =
        await _dio.get<Map<String, dynamic>>('/api/conversations/$id');
    return Conversation.fromJson(response.data!);
  }

  /// POST /api/conversations
  Future<Conversation> createConversation({String? title}) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/api/conversations',
      data: {'title': title ?? 'New Conversation'},
    );
    return Conversation.fromJson(response.data!);
  }

  /// POST /api/suggest-agents
  Future<List<Participant>> suggestAgents(String topic) async {
    final response = await _dio.post<List<dynamic>>(
      '/api/suggest-agents',
      data: {'topic': topic},
    );
    return response.data!
        .map((e) => Participant.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// POST /api/summarize/:conversationId
  Future<String> generateSummary(String conversationId) async {
    final response = await _dio
        .post<Map<String, dynamic>>('/api/summarize/$conversationId');
    return response.data!['summary'] as String;
  }

  /// PATCH /api/conversations/:id — update title
  Future<void> updateTitle(String conversationId, String title) async {
    await _dio.patch<Map<String, dynamic>>(
      '/api/conversations/$conversationId',
      data: {'title': title},
    );
  }

  /// POST /api/nudge/:conversationId
  Future<void> nudge(String conversationId) async {
    await _dio.post<Map<String, dynamic>>('/api/nudge/$conversationId');
  }
}
