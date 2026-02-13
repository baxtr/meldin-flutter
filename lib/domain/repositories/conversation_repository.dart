import '../../data/models/conversation.dart';
import '../../data/models/participant.dart';

abstract class ConversationRepository {
  Future<List<Conversation>> getConversations();
  Future<Conversation> getConversation(String id);
  Future<Conversation> createConversation({String? title});
  Future<List<Participant>> suggestAgents(String topic);
  Future<String> generateSummary(String conversationId);
  Future<void> updateTitle(String conversationId, String title);
  Future<void> nudge(String conversationId);
}
