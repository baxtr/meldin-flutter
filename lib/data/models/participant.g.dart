// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'participant.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Participant _$ParticipantFromJson(Map<String, dynamic> json) => _Participant(
  id: json['id'] as String,
  name: json['name'] as String,
  type: json['type'] as String,
  status: json['status'] as String,
  model: json['model'] as String?,
  systemPrompt: json['systemPrompt'] as String?,
  temperature: (json['temperature'] as num?)?.toDouble(),
  expertise: json['expertise'] as String?,
);

Map<String, dynamic> _$ParticipantToJson(_Participant instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'type': instance.type,
      'status': instance.status,
      'model': instance.model,
      'systemPrompt': instance.systemPrompt,
      'temperature': instance.temperature,
      'expertise': instance.expertise,
    };
