import 'dart:convert';
import 'message.dart';
import 'participant.dart';

sealed class WsMessage {
  Map<String, dynamic> toJson();
  String encode() => jsonEncode(toJson());

  static WsMessage decode(String raw) {
    final json = jsonDecode(raw) as Map<String, dynamic>;
    return switch (json['type']) {
      'message' => WsMessageChat.fromJson(json),
      'join' => WsJoin.fromJson(json),
      'leave' => WsLeave.fromJson(json),
      'typing' => WsTyping.fromJson(json),
      'participants' => WsParticipants.fromJson(json),
      'ping' => WsPing(),
      'pong' => WsPong(),
      'resume' => WsResume.fromJson(json),
      _ => WsUnknown(json),
    };
  }
}

class WsMessageChat extends WsMessage {
  final Message payload;
  WsMessageChat(this.payload);

  factory WsMessageChat.fromJson(Map<String, dynamic> json) =>
      WsMessageChat(Message.fromJson(json['payload'] as Map<String, dynamic>));

  @override
  Map<String, dynamic> toJson() =>
      {'type': 'message', 'payload': payload.toJson()};
}

class WsJoin extends WsMessage {
  final Participant payload;
  WsJoin(this.payload);

  factory WsJoin.fromJson(Map<String, dynamic> json) =>
      WsJoin(Participant.fromJson(json['payload'] as Map<String, dynamic>));

  @override
  Map<String, dynamic> toJson() =>
      {'type': 'join', 'payload': payload.toJson()};
}

class WsLeave extends WsMessage {
  final String participantId;
  WsLeave(this.participantId);

  factory WsLeave.fromJson(Map<String, dynamic> json) =>
      WsLeave(json['payload']['participantId'] as String);

  @override
  Map<String, dynamic> toJson() =>
      {'type': 'leave', 'payload': {'participantId': participantId}};
}

class WsTyping extends WsMessage {
  final String participantId;
  final bool isTyping;
  WsTyping(this.participantId, this.isTyping);

  factory WsTyping.fromJson(Map<String, dynamic> json) => WsTyping(
        json['payload']['participantId'] as String,
        json['payload']['isTyping'] as bool,
      );

  @override
  Map<String, dynamic> toJson() => {
        'type': 'typing',
        'payload': {'participantId': participantId, 'isTyping': isTyping},
      };
}

class WsParticipants extends WsMessage {
  final List<Participant> payload;
  WsParticipants(this.payload);

  factory WsParticipants.fromJson(Map<String, dynamic> json) =>
      WsParticipants(
        (json['payload'] as List)
            .map((p) => Participant.fromJson(p as Map<String, dynamic>))
            .toList(),
      );

  @override
  Map<String, dynamic> toJson() =>
      {'type': 'participants', 'payload': payload.map((p) => p.toJson()).toList()};
}

class WsPing extends WsMessage {
  WsPing();
  @override
  Map<String, dynamic> toJson() => {'type': 'ping'};
}

class WsPong extends WsMessage {
  WsPong();
  @override
  Map<String, dynamic> toJson() => {'type': 'pong'};
}

class WsResume extends WsMessage {
  final String conversationId;
  final String? lastMessageId;
  WsResume(this.conversationId, this.lastMessageId);

  factory WsResume.fromJson(Map<String, dynamic> json) => WsResume(
        json['payload']['conversationId'] as String,
        json['payload']['lastMessageId'] as String?,
      );

  @override
  Map<String, dynamic> toJson() => {
        'type': 'resume',
        'payload': {
          'conversationId': conversationId,
          'lastMessageId': lastMessageId,
        },
      };
}

class WsUnknown extends WsMessage {
  final Map<String, dynamic> raw;
  WsUnknown(this.raw);
  @override
  Map<String, dynamic> toJson() => raw;
}
