// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conversation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Conversation _$ConversationFromJson(Map<String, dynamic> json) =>
    _Conversation(
      id: json['id'] as String,
      title: json['title'] as String,
      participants: (json['participants'] as List<dynamic>)
          .map((e) => Participant.fromJson(e as Map<String, dynamic>))
          .toList(),
      messages: (json['messages'] as List<dynamic>)
          .map((e) => Message.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: (json['createdAt'] as num).toInt(),
    );

Map<String, dynamic> _$ConversationToJson(_Conversation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'participants': instance.participants,
      'messages': instance.messages,
      'createdAt': instance.createdAt,
    };
