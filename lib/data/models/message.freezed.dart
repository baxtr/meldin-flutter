// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'message.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Message {

 String get id; String get content; String get senderId; String get senderName; String get senderType; int get timestamp; String get conversationId; String? get senderExpertise; String? get senderModel; bool get isAnnouncement;
/// Create a copy of Message
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MessageCopyWith<Message> get copyWith => _$MessageCopyWithImpl<Message>(this as Message, _$identity);

  /// Serializes this Message to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Message&&(identical(other.id, id) || other.id == id)&&(identical(other.content, content) || other.content == content)&&(identical(other.senderId, senderId) || other.senderId == senderId)&&(identical(other.senderName, senderName) || other.senderName == senderName)&&(identical(other.senderType, senderType) || other.senderType == senderType)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.conversationId, conversationId) || other.conversationId == conversationId)&&(identical(other.senderExpertise, senderExpertise) || other.senderExpertise == senderExpertise)&&(identical(other.senderModel, senderModel) || other.senderModel == senderModel)&&(identical(other.isAnnouncement, isAnnouncement) || other.isAnnouncement == isAnnouncement));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,content,senderId,senderName,senderType,timestamp,conversationId,senderExpertise,senderModel,isAnnouncement);

@override
String toString() {
  return 'Message(id: $id, content: $content, senderId: $senderId, senderName: $senderName, senderType: $senderType, timestamp: $timestamp, conversationId: $conversationId, senderExpertise: $senderExpertise, senderModel: $senderModel, isAnnouncement: $isAnnouncement)';
}


}

/// @nodoc
abstract mixin class $MessageCopyWith<$Res>  {
  factory $MessageCopyWith(Message value, $Res Function(Message) _then) = _$MessageCopyWithImpl;
@useResult
$Res call({
 String id, String content, String senderId, String senderName, String senderType, int timestamp, String conversationId, String? senderExpertise, String? senderModel, bool isAnnouncement
});




}
/// @nodoc
class _$MessageCopyWithImpl<$Res>
    implements $MessageCopyWith<$Res> {
  _$MessageCopyWithImpl(this._self, this._then);

  final Message _self;
  final $Res Function(Message) _then;

/// Create a copy of Message
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? content = null,Object? senderId = null,Object? senderName = null,Object? senderType = null,Object? timestamp = null,Object? conversationId = null,Object? senderExpertise = freezed,Object? senderModel = freezed,Object? isAnnouncement = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,senderId: null == senderId ? _self.senderId : senderId // ignore: cast_nullable_to_non_nullable
as String,senderName: null == senderName ? _self.senderName : senderName // ignore: cast_nullable_to_non_nullable
as String,senderType: null == senderType ? _self.senderType : senderType // ignore: cast_nullable_to_non_nullable
as String,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as int,conversationId: null == conversationId ? _self.conversationId : conversationId // ignore: cast_nullable_to_non_nullable
as String,senderExpertise: freezed == senderExpertise ? _self.senderExpertise : senderExpertise // ignore: cast_nullable_to_non_nullable
as String?,senderModel: freezed == senderModel ? _self.senderModel : senderModel // ignore: cast_nullable_to_non_nullable
as String?,isAnnouncement: null == isAnnouncement ? _self.isAnnouncement : isAnnouncement // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [Message].
extension MessagePatterns on Message {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Message value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Message() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Message value)  $default,){
final _that = this;
switch (_that) {
case _Message():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Message value)?  $default,){
final _that = this;
switch (_that) {
case _Message() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String content,  String senderId,  String senderName,  String senderType,  int timestamp,  String conversationId,  String? senderExpertise,  String? senderModel,  bool isAnnouncement)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Message() when $default != null:
return $default(_that.id,_that.content,_that.senderId,_that.senderName,_that.senderType,_that.timestamp,_that.conversationId,_that.senderExpertise,_that.senderModel,_that.isAnnouncement);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String content,  String senderId,  String senderName,  String senderType,  int timestamp,  String conversationId,  String? senderExpertise,  String? senderModel,  bool isAnnouncement)  $default,) {final _that = this;
switch (_that) {
case _Message():
return $default(_that.id,_that.content,_that.senderId,_that.senderName,_that.senderType,_that.timestamp,_that.conversationId,_that.senderExpertise,_that.senderModel,_that.isAnnouncement);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String content,  String senderId,  String senderName,  String senderType,  int timestamp,  String conversationId,  String? senderExpertise,  String? senderModel,  bool isAnnouncement)?  $default,) {final _that = this;
switch (_that) {
case _Message() when $default != null:
return $default(_that.id,_that.content,_that.senderId,_that.senderName,_that.senderType,_that.timestamp,_that.conversationId,_that.senderExpertise,_that.senderModel,_that.isAnnouncement);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Message implements Message {
  const _Message({required this.id, required this.content, required this.senderId, required this.senderName, required this.senderType, required this.timestamp, required this.conversationId, this.senderExpertise, this.senderModel, this.isAnnouncement = false});
  factory _Message.fromJson(Map<String, dynamic> json) => _$MessageFromJson(json);

@override final  String id;
@override final  String content;
@override final  String senderId;
@override final  String senderName;
@override final  String senderType;
@override final  int timestamp;
@override final  String conversationId;
@override final  String? senderExpertise;
@override final  String? senderModel;
@override@JsonKey() final  bool isAnnouncement;

/// Create a copy of Message
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MessageCopyWith<_Message> get copyWith => __$MessageCopyWithImpl<_Message>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MessageToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Message&&(identical(other.id, id) || other.id == id)&&(identical(other.content, content) || other.content == content)&&(identical(other.senderId, senderId) || other.senderId == senderId)&&(identical(other.senderName, senderName) || other.senderName == senderName)&&(identical(other.senderType, senderType) || other.senderType == senderType)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.conversationId, conversationId) || other.conversationId == conversationId)&&(identical(other.senderExpertise, senderExpertise) || other.senderExpertise == senderExpertise)&&(identical(other.senderModel, senderModel) || other.senderModel == senderModel)&&(identical(other.isAnnouncement, isAnnouncement) || other.isAnnouncement == isAnnouncement));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,content,senderId,senderName,senderType,timestamp,conversationId,senderExpertise,senderModel,isAnnouncement);

@override
String toString() {
  return 'Message(id: $id, content: $content, senderId: $senderId, senderName: $senderName, senderType: $senderType, timestamp: $timestamp, conversationId: $conversationId, senderExpertise: $senderExpertise, senderModel: $senderModel, isAnnouncement: $isAnnouncement)';
}


}

/// @nodoc
abstract mixin class _$MessageCopyWith<$Res> implements $MessageCopyWith<$Res> {
  factory _$MessageCopyWith(_Message value, $Res Function(_Message) _then) = __$MessageCopyWithImpl;
@override @useResult
$Res call({
 String id, String content, String senderId, String senderName, String senderType, int timestamp, String conversationId, String? senderExpertise, String? senderModel, bool isAnnouncement
});




}
/// @nodoc
class __$MessageCopyWithImpl<$Res>
    implements _$MessageCopyWith<$Res> {
  __$MessageCopyWithImpl(this._self, this._then);

  final _Message _self;
  final $Res Function(_Message) _then;

/// Create a copy of Message
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? content = null,Object? senderId = null,Object? senderName = null,Object? senderType = null,Object? timestamp = null,Object? conversationId = null,Object? senderExpertise = freezed,Object? senderModel = freezed,Object? isAnnouncement = null,}) {
  return _then(_Message(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,senderId: null == senderId ? _self.senderId : senderId // ignore: cast_nullable_to_non_nullable
as String,senderName: null == senderName ? _self.senderName : senderName // ignore: cast_nullable_to_non_nullable
as String,senderType: null == senderType ? _self.senderType : senderType // ignore: cast_nullable_to_non_nullable
as String,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as int,conversationId: null == conversationId ? _self.conversationId : conversationId // ignore: cast_nullable_to_non_nullable
as String,senderExpertise: freezed == senderExpertise ? _self.senderExpertise : senderExpertise // ignore: cast_nullable_to_non_nullable
as String?,senderModel: freezed == senderModel ? _self.senderModel : senderModel // ignore: cast_nullable_to_non_nullable
as String?,isAnnouncement: null == isAnnouncement ? _self.isAnnouncement : isAnnouncement // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
