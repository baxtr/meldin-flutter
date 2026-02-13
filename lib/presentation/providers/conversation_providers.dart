import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/conversation.dart';
import '../../data/services/api_client.dart';
import '../../data/repositories/conversation_repository_impl.dart';
import '../../domain/repositories/conversation_repository.dart';

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

final conversationRepoProvider = Provider<ConversationRepository>(
  (ref) => ConversationRepositoryImpl(ref.read(apiClientProvider)),
);

final conversationsProvider = FutureProvider<List<Conversation>>((ref) {
  return ref.read(conversationRepoProvider).getConversations();
});

final conversationProvider =
    FutureProvider.family<Conversation, String>((ref, id) {
  return ref.read(conversationRepoProvider).getConversation(id);
});
