import '../../domain/repositories/conversation_repository.dart';
import '../models/conversation.dart';
import '../models/participant.dart';
import '../services/api_client.dart';

class ConversationRepositoryImpl implements ConversationRepository {
  final ApiClient _apiClient;

  ConversationRepositoryImpl(this._apiClient);

  @override
  Future<List<Conversation>> getConversations() =>
      _apiClient.getConversations();

  @override
  Future<Conversation> getConversation(String id) =>
      _apiClient.getConversation(id);

  @override
  Future<Conversation> createConversation({String? title}) =>
      _apiClient.createConversation(title: title);

  @override
  Future<List<Participant>> suggestAgents(String topic) =>
      _apiClient.suggestAgents(topic);

  @override
  Future<String> generateSummary(String conversationId) =>
      _apiClient.generateSummary(conversationId);

  @override
  Future<void> updateTitle(String conversationId, String title) =>
      _apiClient.updateTitle(conversationId, title);

  @override
  Future<void> nudge(String conversationId) =>
      _apiClient.nudge(conversationId);
}
