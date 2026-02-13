// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'participant.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Participant {

 String get id; String get name; String get type; String get status; String? get model; String? get systemPrompt; double? get temperature; String? get expertise;
/// Create a copy of Participant
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ParticipantCopyWith<Participant> get copyWith => _$ParticipantCopyWithImpl<Participant>(this as Participant, _$identity);

  /// Serializes this Participant to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Participant&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.type, type) || other.type == type)&&(identical(other.status, status) || other.status == status)&&(identical(other.model, model) || other.model == model)&&(identical(other.systemPrompt, systemPrompt) || other.systemPrompt == systemPrompt)&&(identical(other.temperature, temperature) || other.temperature == temperature)&&(identical(other.expertise, expertise) || other.expertise == expertise));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,type,status,model,systemPrompt,temperature,expertise);

@override
String toString() {
  return 'Participant(id: $id, name: $name, type: $type, status: $status, model: $model, systemPrompt: $systemPrompt, temperature: $temperature, expertise: $expertise)';
}


}

/// @nodoc
abstract mixin class $ParticipantCopyWith<$Res>  {
  factory $ParticipantCopyWith(Participant value, $Res Function(Participant) _then) = _$ParticipantCopyWithImpl;
@useResult
$Res call({
 String id, String name, String type, String status, String? model, String? systemPrompt, double? temperature, String? expertise
});




}
/// @nodoc
class _$ParticipantCopyWithImpl<$Res>
    implements $ParticipantCopyWith<$Res> {
  _$ParticipantCopyWithImpl(this._self, this._then);

  final Participant _self;
  final $Res Function(Participant) _then;

/// Create a copy of Participant
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? type = null,Object? status = null,Object? model = freezed,Object? systemPrompt = freezed,Object? temperature = freezed,Object? expertise = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,model: freezed == model ? _self.model : model // ignore: cast_nullable_to_non_nullable
as String?,systemPrompt: freezed == systemPrompt ? _self.systemPrompt : systemPrompt // ignore: cast_nullable_to_non_nullable
as String?,temperature: freezed == temperature ? _self.temperature : temperature // ignore: cast_nullable_to_non_nullable
as double?,expertise: freezed == expertise ? _self.expertise : expertise // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Participant].
extension ParticipantPatterns on Participant {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Participant value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Participant() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Participant value)  $default,){
final _that = this;
switch (_that) {
case _Participant():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Participant value)?  $default,){
final _that = this;
switch (_that) {
case _Participant() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String type,  String status,  String? model,  String? systemPrompt,  double? temperature,  String? expertise)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Participant() when $default != null:
return $default(_that.id,_that.name,_that.type,_that.status,_that.model,_that.systemPrompt,_that.temperature,_that.expertise);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String type,  String status,  String? model,  String? systemPrompt,  double? temperature,  String? expertise)  $default,) {final _that = this;
switch (_that) {
case _Participant():
return $default(_that.id,_that.name,_that.type,_that.status,_that.model,_that.systemPrompt,_that.temperature,_that.expertise);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String type,  String status,  String? model,  String? systemPrompt,  double? temperature,  String? expertise)?  $default,) {final _that = this;
switch (_that) {
case _Participant() when $default != null:
return $default(_that.id,_that.name,_that.type,_that.status,_that.model,_that.systemPrompt,_that.temperature,_that.expertise);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Participant implements Participant {
  const _Participant({required this.id, required this.name, required this.type, required this.status, this.model, this.systemPrompt, this.temperature, this.expertise});
  factory _Participant.fromJson(Map<String, dynamic> json) => _$ParticipantFromJson(json);

@override final  String id;
@override final  String name;
@override final  String type;
@override final  String status;
@override final  String? model;
@override final  String? systemPrompt;
@override final  double? temperature;
@override final  String? expertise;

/// Create a copy of Participant
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ParticipantCopyWith<_Participant> get copyWith => __$ParticipantCopyWithImpl<_Participant>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ParticipantToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Participant&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.type, type) || other.type == type)&&(identical(other.status, status) || other.status == status)&&(identical(other.model, model) || other.model == model)&&(identical(other.systemPrompt, systemPrompt) || other.systemPrompt == systemPrompt)&&(identical(other.temperature, temperature) || other.temperature == temperature)&&(identical(other.expertise, expertise) || other.expertise == expertise));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,type,status,model,systemPrompt,temperature,expertise);

@override
String toString() {
  return 'Participant(id: $id, name: $name, type: $type, status: $status, model: $model, systemPrompt: $systemPrompt, temperature: $temperature, expertise: $expertise)';
}


}

/// @nodoc
abstract mixin class _$ParticipantCopyWith<$Res> implements $ParticipantCopyWith<$Res> {
  factory _$ParticipantCopyWith(_Participant value, $Res Function(_Participant) _then) = __$ParticipantCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String type, String status, String? model, String? systemPrompt, double? temperature, String? expertise
});




}
/// @nodoc
class __$ParticipantCopyWithImpl<$Res>
    implements _$ParticipantCopyWith<$Res> {
  __$ParticipantCopyWithImpl(this._self, this._then);

  final _Participant _self;
  final $Res Function(_Participant) _then;

/// Create a copy of Participant
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? type = null,Object? status = null,Object? model = freezed,Object? systemPrompt = freezed,Object? temperature = freezed,Object? expertise = freezed,}) {
  return _then(_Participant(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,model: freezed == model ? _self.model : model // ignore: cast_nullable_to_non_nullable
as String?,systemPrompt: freezed == systemPrompt ? _self.systemPrompt : systemPrompt // ignore: cast_nullable_to_non_nullable
as String?,temperature: freezed == temperature ? _self.temperature : temperature // ignore: cast_nullable_to_non_nullable
as double?,expertise: freezed == expertise ? _self.expertise : expertise // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
