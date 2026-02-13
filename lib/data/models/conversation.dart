import 'package:freezed_annotation/freezed_annotation.dart';
import 'message.dart';
import 'participant.dart';

part 'conversation.freezed.dart';
part 'conversation.g.dart';

@freezed
abstract class Conversation with _$Conversation {
  const factory Conversation({
    required String id,
    required String title,
    required List<Participant> participants,
    required List<Message> messages,
    required int createdAt,
  }) = _Conversation;

  factory Conversation.fromJson(Map<String, dynamic> json) =>
      _$ConversationFromJson(json);
}
