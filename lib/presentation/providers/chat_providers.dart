import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/message.dart';
import '../../data/models/participant.dart';
import '../../data/models/websocket_message.dart';
import 'websocket_provider.dart';

// ---------- Messages ----------

final messagesProvider =
    StateNotifierProvider.family.autoDispose<MessagesNotifier, List<Message>, String>(
  (ref, conversationId) {
    final service = ref.watch(wsServiceProvider(conversationId));
    return MessagesNotifier(service.messageStream, conversationId);
  },
);

class MessagesNotifier extends StateNotifier<List<Message>> {
  late final StreamSubscription<WsMessage> _sub;
  final String conversationId;
  String? _lastMessageId;

  String? get lastMessageId => _lastMessageId;

  MessagesNotifier(Stream<WsMessage> stream, this.conversationId) : super([]) {
    _sub = stream.listen(_onMessage);
  }

  void _onMessage(WsMessage msg) {
    switch (msg) {
      case WsMessageChat(:final payload):
        if (state.any((m) => m.id == payload.id)) return;
        _lastMessageId = payload.id;
        state = [...state, payload];

      case WsJoin(:final payload) when payload.type == 'agent':
        final announcement = Message(
          id: 'announcement-${payload.id}-${DateTime.now().millisecondsSinceEpoch}',
          content: '',
          senderId: 'system',
          senderName: payload.name,
          senderType: 'agent',
          timestamp: DateTime.now().millisecondsSinceEpoch,
          conversationId: conversationId,
          senderExpertise: payload.expertise,
          senderModel: payload.model,
          isAnnouncement: true,
        );
        state = [...state, announcement];

      default:
        break;
    }
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}

// ---------- Participants ----------

final participantsProvider =
    StateNotifierProvider.family.autoDispose<ParticipantsNotifier, List<Participant>, String>(
  (ref, conversationId) {
    final service = ref.watch(wsServiceProvider(conversationId));
    return ParticipantsNotifier(service.messageStream);
  },
);

class ParticipantsNotifier extends StateNotifier<List<Participant>> {
  late final StreamSubscription<WsMessage> _sub;

  ParticipantsNotifier(Stream<WsMessage> stream) : super([]) {
    _sub = stream.listen(_onMessage);
  }

  void _onMessage(WsMessage msg) {
    switch (msg) {
      case WsParticipants(:final payload):
        if (state.isEmpty) {
          state = payload;
        } else {
          final merged = [...state];
          for (final np in payload) {
            if (!merged.any((p) => p.id == np.id)) merged.add(np);
          }
          state = merged;
        }

      case WsJoin(:final payload):
        if (!state.any((p) => p.id == payload.id)) {
          state = [...state, payload];
        }

      case WsLeave(:final participantId):
        state = state.where((p) => p.id != participantId).toList();

      case WsTyping(:final participantId, :final isTyping):
        state = state.map((p) {
          if (p.id == participantId) {
            return p.copyWith(status: isTyping ? 'typing' : 'online');
          }
          return p;
        }).toList();

      default:
        break;
    }
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
