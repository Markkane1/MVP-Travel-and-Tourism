// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'concierge_thread.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ConciergeThread {

@JsonKey(includeToJson: false) String get id;@JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson) DateTime? get lastMessageAt; String? get lastMessageText; String? get lastMessageSender; bool get isTyping; bool get hasUnreadUserMessage;
/// Create a copy of ConciergeThread
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ConciergeThreadCopyWith<ConciergeThread> get copyWith => _$ConciergeThreadCopyWithImpl<ConciergeThread>(this as ConciergeThread, _$identity);

  /// Serializes this ConciergeThread to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ConciergeThread&&(identical(other.id, id) || other.id == id)&&(identical(other.lastMessageAt, lastMessageAt) || other.lastMessageAt == lastMessageAt)&&(identical(other.lastMessageText, lastMessageText) || other.lastMessageText == lastMessageText)&&(identical(other.lastMessageSender, lastMessageSender) || other.lastMessageSender == lastMessageSender)&&(identical(other.isTyping, isTyping) || other.isTyping == isTyping)&&(identical(other.hasUnreadUserMessage, hasUnreadUserMessage) || other.hasUnreadUserMessage == hasUnreadUserMessage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,lastMessageAt,lastMessageText,lastMessageSender,isTyping,hasUnreadUserMessage);

@override
String toString() {
  return 'ConciergeThread(id: $id, lastMessageAt: $lastMessageAt, lastMessageText: $lastMessageText, lastMessageSender: $lastMessageSender, isTyping: $isTyping, hasUnreadUserMessage: $hasUnreadUserMessage)';
}


}

/// @nodoc
abstract mixin class $ConciergeThreadCopyWith<$Res>  {
  factory $ConciergeThreadCopyWith(ConciergeThread value, $Res Function(ConciergeThread) _then) = _$ConciergeThreadCopyWithImpl;
@useResult
$Res call({
@JsonKey(includeToJson: false) String id,@JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson) DateTime? lastMessageAt, String? lastMessageText, String? lastMessageSender, bool isTyping, bool hasUnreadUserMessage
});




}
/// @nodoc
class _$ConciergeThreadCopyWithImpl<$Res>
    implements $ConciergeThreadCopyWith<$Res> {
  _$ConciergeThreadCopyWithImpl(this._self, this._then);

  final ConciergeThread _self;
  final $Res Function(ConciergeThread) _then;

/// Create a copy of ConciergeThread
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? lastMessageAt = freezed,Object? lastMessageText = freezed,Object? lastMessageSender = freezed,Object? isTyping = null,Object? hasUnreadUserMessage = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,lastMessageAt: freezed == lastMessageAt ? _self.lastMessageAt : lastMessageAt // ignore: cast_nullable_to_non_nullable
as DateTime?,lastMessageText: freezed == lastMessageText ? _self.lastMessageText : lastMessageText // ignore: cast_nullable_to_non_nullable
as String?,lastMessageSender: freezed == lastMessageSender ? _self.lastMessageSender : lastMessageSender // ignore: cast_nullable_to_non_nullable
as String?,isTyping: null == isTyping ? _self.isTyping : isTyping // ignore: cast_nullable_to_non_nullable
as bool,hasUnreadUserMessage: null == hasUnreadUserMessage ? _self.hasUnreadUserMessage : hasUnreadUserMessage // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [ConciergeThread].
extension ConciergeThreadPatterns on ConciergeThread {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ConciergeThread value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ConciergeThread() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ConciergeThread value)  $default,){
final _that = this;
switch (_that) {
case _ConciergeThread():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ConciergeThread value)?  $default,){
final _that = this;
switch (_that) {
case _ConciergeThread() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(includeToJson: false)  String id, @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)  DateTime? lastMessageAt,  String? lastMessageText,  String? lastMessageSender,  bool isTyping,  bool hasUnreadUserMessage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ConciergeThread() when $default != null:
return $default(_that.id,_that.lastMessageAt,_that.lastMessageText,_that.lastMessageSender,_that.isTyping,_that.hasUnreadUserMessage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(includeToJson: false)  String id, @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)  DateTime? lastMessageAt,  String? lastMessageText,  String? lastMessageSender,  bool isTyping,  bool hasUnreadUserMessage)  $default,) {final _that = this;
switch (_that) {
case _ConciergeThread():
return $default(_that.id,_that.lastMessageAt,_that.lastMessageText,_that.lastMessageSender,_that.isTyping,_that.hasUnreadUserMessage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(includeToJson: false)  String id, @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)  DateTime? lastMessageAt,  String? lastMessageText,  String? lastMessageSender,  bool isTyping,  bool hasUnreadUserMessage)?  $default,) {final _that = this;
switch (_that) {
case _ConciergeThread() when $default != null:
return $default(_that.id,_that.lastMessageAt,_that.lastMessageText,_that.lastMessageSender,_that.isTyping,_that.hasUnreadUserMessage);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ConciergeThread extends ConciergeThread {
  const _ConciergeThread({@JsonKey(includeToJson: false) this.id = '', @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson) this.lastMessageAt, this.lastMessageText, this.lastMessageSender, this.isTyping = false, this.hasUnreadUserMessage = false}): super._();
  factory _ConciergeThread.fromJson(Map<String, dynamic> json) => _$ConciergeThreadFromJson(json);

@override@JsonKey(includeToJson: false) final  String id;
@override@JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson) final  DateTime? lastMessageAt;
@override final  String? lastMessageText;
@override final  String? lastMessageSender;
@override@JsonKey() final  bool isTyping;
@override@JsonKey() final  bool hasUnreadUserMessage;

/// Create a copy of ConciergeThread
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ConciergeThreadCopyWith<_ConciergeThread> get copyWith => __$ConciergeThreadCopyWithImpl<_ConciergeThread>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ConciergeThreadToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ConciergeThread&&(identical(other.id, id) || other.id == id)&&(identical(other.lastMessageAt, lastMessageAt) || other.lastMessageAt == lastMessageAt)&&(identical(other.lastMessageText, lastMessageText) || other.lastMessageText == lastMessageText)&&(identical(other.lastMessageSender, lastMessageSender) || other.lastMessageSender == lastMessageSender)&&(identical(other.isTyping, isTyping) || other.isTyping == isTyping)&&(identical(other.hasUnreadUserMessage, hasUnreadUserMessage) || other.hasUnreadUserMessage == hasUnreadUserMessage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,lastMessageAt,lastMessageText,lastMessageSender,isTyping,hasUnreadUserMessage);

@override
String toString() {
  return 'ConciergeThread(id: $id, lastMessageAt: $lastMessageAt, lastMessageText: $lastMessageText, lastMessageSender: $lastMessageSender, isTyping: $isTyping, hasUnreadUserMessage: $hasUnreadUserMessage)';
}


}

/// @nodoc
abstract mixin class _$ConciergeThreadCopyWith<$Res> implements $ConciergeThreadCopyWith<$Res> {
  factory _$ConciergeThreadCopyWith(_ConciergeThread value, $Res Function(_ConciergeThread) _then) = __$ConciergeThreadCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(includeToJson: false) String id,@JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson) DateTime? lastMessageAt, String? lastMessageText, String? lastMessageSender, bool isTyping, bool hasUnreadUserMessage
});




}
/// @nodoc
class __$ConciergeThreadCopyWithImpl<$Res>
    implements _$ConciergeThreadCopyWith<$Res> {
  __$ConciergeThreadCopyWithImpl(this._self, this._then);

  final _ConciergeThread _self;
  final $Res Function(_ConciergeThread) _then;

/// Create a copy of ConciergeThread
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? lastMessageAt = freezed,Object? lastMessageText = freezed,Object? lastMessageSender = freezed,Object? isTyping = null,Object? hasUnreadUserMessage = null,}) {
  return _then(_ConciergeThread(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,lastMessageAt: freezed == lastMessageAt ? _self.lastMessageAt : lastMessageAt // ignore: cast_nullable_to_non_nullable
as DateTime?,lastMessageText: freezed == lastMessageText ? _self.lastMessageText : lastMessageText // ignore: cast_nullable_to_non_nullable
as String?,lastMessageSender: freezed == lastMessageSender ? _self.lastMessageSender : lastMessageSender // ignore: cast_nullable_to_non_nullable
as String?,isTyping: null == isTyping ? _self.isTyping : isTyping // ignore: cast_nullable_to_non_nullable
as bool,hasUnreadUserMessage: null == hasUnreadUserMessage ? _self.hasUnreadUserMessage : hasUnreadUserMessage // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$ConciergeMessage {

@JsonKey(includeToJson: false) String get id; String get senderId; String get senderType; String get text;@JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson) DateTime? get createdAt;
/// Create a copy of ConciergeMessage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ConciergeMessageCopyWith<ConciergeMessage> get copyWith => _$ConciergeMessageCopyWithImpl<ConciergeMessage>(this as ConciergeMessage, _$identity);

  /// Serializes this ConciergeMessage to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ConciergeMessage&&(identical(other.id, id) || other.id == id)&&(identical(other.senderId, senderId) || other.senderId == senderId)&&(identical(other.senderType, senderType) || other.senderType == senderType)&&(identical(other.text, text) || other.text == text)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,senderId,senderType,text,createdAt);

@override
String toString() {
  return 'ConciergeMessage(id: $id, senderId: $senderId, senderType: $senderType, text: $text, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $ConciergeMessageCopyWith<$Res>  {
  factory $ConciergeMessageCopyWith(ConciergeMessage value, $Res Function(ConciergeMessage) _then) = _$ConciergeMessageCopyWithImpl;
@useResult
$Res call({
@JsonKey(includeToJson: false) String id, String senderId, String senderType, String text,@JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson) DateTime? createdAt
});




}
/// @nodoc
class _$ConciergeMessageCopyWithImpl<$Res>
    implements $ConciergeMessageCopyWith<$Res> {
  _$ConciergeMessageCopyWithImpl(this._self, this._then);

  final ConciergeMessage _self;
  final $Res Function(ConciergeMessage) _then;

/// Create a copy of ConciergeMessage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? senderId = null,Object? senderType = null,Object? text = null,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,senderId: null == senderId ? _self.senderId : senderId // ignore: cast_nullable_to_non_nullable
as String,senderType: null == senderType ? _self.senderType : senderType // ignore: cast_nullable_to_non_nullable
as String,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [ConciergeMessage].
extension ConciergeMessagePatterns on ConciergeMessage {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ConciergeMessage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ConciergeMessage() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ConciergeMessage value)  $default,){
final _that = this;
switch (_that) {
case _ConciergeMessage():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ConciergeMessage value)?  $default,){
final _that = this;
switch (_that) {
case _ConciergeMessage() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(includeToJson: false)  String id,  String senderId,  String senderType,  String text, @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ConciergeMessage() when $default != null:
return $default(_that.id,_that.senderId,_that.senderType,_that.text,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(includeToJson: false)  String id,  String senderId,  String senderType,  String text, @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _ConciergeMessage():
return $default(_that.id,_that.senderId,_that.senderType,_that.text,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(includeToJson: false)  String id,  String senderId,  String senderType,  String text, @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _ConciergeMessage() when $default != null:
return $default(_that.id,_that.senderId,_that.senderType,_that.text,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ConciergeMessage extends ConciergeMessage {
  const _ConciergeMessage({@JsonKey(includeToJson: false) this.id = '', required this.senderId, required this.senderType, required this.text, @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson) this.createdAt}): super._();
  factory _ConciergeMessage.fromJson(Map<String, dynamic> json) => _$ConciergeMessageFromJson(json);

@override@JsonKey(includeToJson: false) final  String id;
@override final  String senderId;
@override final  String senderType;
@override final  String text;
@override@JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson) final  DateTime? createdAt;

/// Create a copy of ConciergeMessage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ConciergeMessageCopyWith<_ConciergeMessage> get copyWith => __$ConciergeMessageCopyWithImpl<_ConciergeMessage>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ConciergeMessageToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ConciergeMessage&&(identical(other.id, id) || other.id == id)&&(identical(other.senderId, senderId) || other.senderId == senderId)&&(identical(other.senderType, senderType) || other.senderType == senderType)&&(identical(other.text, text) || other.text == text)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,senderId,senderType,text,createdAt);

@override
String toString() {
  return 'ConciergeMessage(id: $id, senderId: $senderId, senderType: $senderType, text: $text, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$ConciergeMessageCopyWith<$Res> implements $ConciergeMessageCopyWith<$Res> {
  factory _$ConciergeMessageCopyWith(_ConciergeMessage value, $Res Function(_ConciergeMessage) _then) = __$ConciergeMessageCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(includeToJson: false) String id, String senderId, String senderType, String text,@JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson) DateTime? createdAt
});




}
/// @nodoc
class __$ConciergeMessageCopyWithImpl<$Res>
    implements _$ConciergeMessageCopyWith<$Res> {
  __$ConciergeMessageCopyWithImpl(this._self, this._then);

  final _ConciergeMessage _self;
  final $Res Function(_ConciergeMessage) _then;

/// Create a copy of ConciergeMessage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? senderId = null,Object? senderType = null,Object? text = null,Object? createdAt = freezed,}) {
  return _then(_ConciergeMessage(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,senderId: null == senderId ? _self.senderId : senderId // ignore: cast_nullable_to_non_nullable
as String,senderType: null == senderType ? _self.senderType : senderType // ignore: cast_nullable_to_non_nullable
as String,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
