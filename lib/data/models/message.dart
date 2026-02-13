import 'package:freezed_annotation/freezed_annotation.dart';

part 'message.freezed.dart';
part 'message.g.dart';

@freezed
abstract class Message with _$Message {
  const factory Message({
    required String id,
    required String content,
    required String senderId,
    required String senderName,
    required String senderType,
    required int timestamp,
    required String conversationId,
    String? senderExpertise,
    String? senderModel,
    @Default(false) bool isAnnouncement,
  }) = _Message;

  factory Message.fromJson(Map<String, dynamic> json) =>
      _$MessageFromJson(json);
}
