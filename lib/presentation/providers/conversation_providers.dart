import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/conversation.dart';
import '../../data/services/api_client.dart';
import '../../data/repositories/conversation_repository_impl.dart';
import '../../domain/repositories/conversation_repository.dart';
import 'session_provider.dart' show ConversationHistory;

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

final conversationRepoProvider = Provider<ConversationRepository>(
  (ref) => ConversationRepositoryImpl(ref.read(apiClientProvider)),
);

/// Global conversation list (all conversations on the server).
final conversationsProvider = FutureProvider<List<Conversation>>((ref) {
  return ref.read(conversationRepoProvider).getConversations();
});

/// Local-only: conversations this device has participated in.
final localConversationsProvider = FutureProvider<List<Conversation>>((ref) async {
  final ids = await ConversationHistory.getIds();
  if (ids.isEmpty) return [];

  final repo = ref.read(conversationRepoProvider);
  final results = await Future.wait(
    ids.map((id) async {
      try {
        return await repo.getConversation(id);
      } catch (_) {
        return null;
      }
    }),
  );
  return results.whereType<Conversation>().toList();
});

final conversationProvider =
    FutureProvider.family<Conversation, String>((ref, id) {
  return ref.read(conversationRepoProvider).getConversation(id);
});
