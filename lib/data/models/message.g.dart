// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Message _$MessageFromJson(Map<String, dynamic> json) => _Message(
  id: json['id'] as String,
  content: json['content'] as String,
  senderId: json['senderId'] as String,
  senderName: json['senderName'] as String,
  senderType: json['senderType'] as String,
  timestamp: (json['timestamp'] as num).toInt(),
  conversationId: json['conversationId'] as String,
  senderExpertise: json['senderExpertise'] as String?,
  senderModel: json['senderModel'] as String?,
  isAnnouncement: json['isAnnouncement'] as bool? ?? false,
);

Map<String, dynamic> _$MessageToJson(_Message instance) => <String, dynamic>{
  'id': instance.id,
  'content': instance.content,
  'senderId': instance.senderId,
  'senderName': instance.senderName,
  'senderType': instance.senderType,
  'timestamp': instance.timestamp,
  'conversationId': instance.conversationId,
  'senderExpertise': instance.senderExpertise,
  'senderModel': instance.senderModel,
  'isAnnouncement': instance.isAnnouncement,
};
