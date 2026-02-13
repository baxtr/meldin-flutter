import 'package:freezed_annotation/freezed_annotation.dart';

part 'participant.freezed.dart';
part 'participant.g.dart';

@freezed
abstract class Participant with _$Participant {
  const factory Participant({
    required String id,
    required String name,
    required String type,
    required String status,
    String? model,
    String? systemPrompt,
    double? temperature,
    String? expertise,
  }) = _Participant;

  factory Participant.fromJson(Map<String, dynamic> json) =>
      _$ParticipantFromJson(json);
}
