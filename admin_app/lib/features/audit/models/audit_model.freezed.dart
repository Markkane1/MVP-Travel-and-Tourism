// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'audit_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AuditModel {

@JsonKey(includeToJson: false) String get id; String get actorUid; String get actorEmail; String get actorRole; String get action; String get targetType; String get targetId; String get summary; Map<String, dynamic>? get before; Map<String, dynamic>? get after; String? get reason;@JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson) DateTime? get createdAt;
/// Create a copy of AuditModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuditModelCopyWith<AuditModel> get copyWith => _$AuditModelCopyWithImpl<AuditModel>(this as AuditModel, _$identity);

  /// Serializes this AuditModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuditModel&&(identical(other.id, id) || other.id == id)&&(identical(other.actorUid, actorUid) || other.actorUid == actorUid)&&(identical(other.actorEmail, actorEmail) || other.actorEmail == actorEmail)&&(identical(other.actorRole, actorRole) || other.actorRole == actorRole)&&(identical(other.action, action) || other.action == action)&&(identical(other.targetType, targetType) || other.targetType == targetType)&&(identical(other.targetId, targetId) || other.targetId == targetId)&&(identical(other.summary, summary) || other.summary == summary)&&const DeepCollectionEquality().equals(other.before, before)&&const DeepCollectionEquality().equals(other.after, after)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,actorUid,actorEmail,actorRole,action,targetType,targetId,summary,const DeepCollectionEquality().hash(before),const DeepCollectionEquality().hash(after),reason,createdAt);

@override
String toString() {
  return 'AuditModel(id: $id, actorUid: $actorUid, actorEmail: $actorEmail, actorRole: $actorRole, action: $action, targetType: $targetType, targetId: $targetId, summary: $summary, before: $before, after: $after, reason: $reason, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $AuditModelCopyWith<$Res>  {
  factory $AuditModelCopyWith(AuditModel value, $Res Function(AuditModel) _then) = _$AuditModelCopyWithImpl;
@useResult
$Res call({
@JsonKey(includeToJson: false) String id, String actorUid, String actorEmail, String actorRole, String action, String targetType, String targetId, String summary, Map<String, dynamic>? before, Map<String, dynamic>? after, String? reason,@JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson) DateTime? createdAt
});




}
/// @nodoc
class _$AuditModelCopyWithImpl<$Res>
    implements $AuditModelCopyWith<$Res> {
  _$AuditModelCopyWithImpl(this._self, this._then);

  final AuditModel _self;
  final $Res Function(AuditModel) _then;

/// Create a copy of AuditModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? actorUid = null,Object? actorEmail = null,Object? actorRole = null,Object? action = null,Object? targetType = null,Object? targetId = null,Object? summary = null,Object? before = freezed,Object? after = freezed,Object? reason = freezed,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,actorUid: null == actorUid ? _self.actorUid : actorUid // ignore: cast_nullable_to_non_nullable
as String,actorEmail: null == actorEmail ? _self.actorEmail : actorEmail // ignore: cast_nullable_to_non_nullable
as String,actorRole: null == actorRole ? _self.actorRole : actorRole // ignore: cast_nullable_to_non_nullable
as String,action: null == action ? _self.action : action // ignore: cast_nullable_to_non_nullable
as String,targetType: null == targetType ? _self.targetType : targetType // ignore: cast_nullable_to_non_nullable
as String,targetId: null == targetId ? _self.targetId : targetId // ignore: cast_nullable_to_non_nullable
as String,summary: null == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as String,before: freezed == before ? _self.before : before // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,after: freezed == after ? _self.after : after // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,reason: freezed == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [AuditModel].
extension AuditModelPatterns on AuditModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AuditModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AuditModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AuditModel value)  $default,){
final _that = this;
switch (_that) {
case _AuditModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AuditModel value)?  $default,){
final _that = this;
switch (_that) {
case _AuditModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(includeToJson: false)  String id,  String actorUid,  String actorEmail,  String actorRole,  String action,  String targetType,  String targetId,  String summary,  Map<String, dynamic>? before,  Map<String, dynamic>? after,  String? reason, @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AuditModel() when $default != null:
return $default(_that.id,_that.actorUid,_that.actorEmail,_that.actorRole,_that.action,_that.targetType,_that.targetId,_that.summary,_that.before,_that.after,_that.reason,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(includeToJson: false)  String id,  String actorUid,  String actorEmail,  String actorRole,  String action,  String targetType,  String targetId,  String summary,  Map<String, dynamic>? before,  Map<String, dynamic>? after,  String? reason, @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _AuditModel():
return $default(_that.id,_that.actorUid,_that.actorEmail,_that.actorRole,_that.action,_that.targetType,_that.targetId,_that.summary,_that.before,_that.after,_that.reason,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(includeToJson: false)  String id,  String actorUid,  String actorEmail,  String actorRole,  String action,  String targetType,  String targetId,  String summary,  Map<String, dynamic>? before,  Map<String, dynamic>? after,  String? reason, @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _AuditModel() when $default != null:
return $default(_that.id,_that.actorUid,_that.actorEmail,_that.actorRole,_that.action,_that.targetType,_that.targetId,_that.summary,_that.before,_that.after,_that.reason,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AuditModel extends AuditModel {
  const _AuditModel({@JsonKey(includeToJson: false) this.id = '', this.actorUid = '', this.actorEmail = '', this.actorRole = '', this.action = '', this.targetType = '', this.targetId = '', this.summary = '', final  Map<String, dynamic>? before, final  Map<String, dynamic>? after, this.reason, @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson) this.createdAt}): _before = before,_after = after,super._();
  factory _AuditModel.fromJson(Map<String, dynamic> json) => _$AuditModelFromJson(json);

@override@JsonKey(includeToJson: false) final  String id;
@override@JsonKey() final  String actorUid;
@override@JsonKey() final  String actorEmail;
@override@JsonKey() final  String actorRole;
@override@JsonKey() final  String action;
@override@JsonKey() final  String targetType;
@override@JsonKey() final  String targetId;
@override@JsonKey() final  String summary;
 final  Map<String, dynamic>? _before;
@override Map<String, dynamic>? get before {
  final value = _before;
  if (value == null) return null;
  if (_before is EqualUnmodifiableMapView) return _before;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

 final  Map<String, dynamic>? _after;
@override Map<String, dynamic>? get after {
  final value = _after;
  if (value == null) return null;
  if (_after is EqualUnmodifiableMapView) return _after;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override final  String? reason;
@override@JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson) final  DateTime? createdAt;

/// Create a copy of AuditModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AuditModelCopyWith<_AuditModel> get copyWith => __$AuditModelCopyWithImpl<_AuditModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AuditModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AuditModel&&(identical(other.id, id) || other.id == id)&&(identical(other.actorUid, actorUid) || other.actorUid == actorUid)&&(identical(other.actorEmail, actorEmail) || other.actorEmail == actorEmail)&&(identical(other.actorRole, actorRole) || other.actorRole == actorRole)&&(identical(other.action, action) || other.action == action)&&(identical(other.targetType, targetType) || other.targetType == targetType)&&(identical(other.targetId, targetId) || other.targetId == targetId)&&(identical(other.summary, summary) || other.summary == summary)&&const DeepCollectionEquality().equals(other._before, _before)&&const DeepCollectionEquality().equals(other._after, _after)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,actorUid,actorEmail,actorRole,action,targetType,targetId,summary,const DeepCollectionEquality().hash(_before),const DeepCollectionEquality().hash(_after),reason,createdAt);

@override
String toString() {
  return 'AuditModel(id: $id, actorUid: $actorUid, actorEmail: $actorEmail, actorRole: $actorRole, action: $action, targetType: $targetType, targetId: $targetId, summary: $summary, before: $before, after: $after, reason: $reason, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$AuditModelCopyWith<$Res> implements $AuditModelCopyWith<$Res> {
  factory _$AuditModelCopyWith(_AuditModel value, $Res Function(_AuditModel) _then) = __$AuditModelCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(includeToJson: false) String id, String actorUid, String actorEmail, String actorRole, String action, String targetType, String targetId, String summary, Map<String, dynamic>? before, Map<String, dynamic>? after, String? reason,@JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson) DateTime? createdAt
});




}
/// @nodoc
class __$AuditModelCopyWithImpl<$Res>
    implements _$AuditModelCopyWith<$Res> {
  __$AuditModelCopyWithImpl(this._self, this._then);

  final _AuditModel _self;
  final $Res Function(_AuditModel) _then;

/// Create a copy of AuditModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? actorUid = null,Object? actorEmail = null,Object? actorRole = null,Object? action = null,Object? targetType = null,Object? targetId = null,Object? summary = null,Object? before = freezed,Object? after = freezed,Object? reason = freezed,Object? createdAt = freezed,}) {
  return _then(_AuditModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,actorUid: null == actorUid ? _self.actorUid : actorUid // ignore: cast_nullable_to_non_nullable
as String,actorEmail: null == actorEmail ? _self.actorEmail : actorEmail // ignore: cast_nullable_to_non_nullable
as String,actorRole: null == actorRole ? _self.actorRole : actorRole // ignore: cast_nullable_to_non_nullable
as String,action: null == action ? _self.action : action // ignore: cast_nullable_to_non_nullable
as String,targetType: null == targetType ? _self.targetType : targetType // ignore: cast_nullable_to_non_nullable
as String,targetId: null == targetId ? _self.targetId : targetId // ignore: cast_nullable_to_non_nullable
as String,summary: null == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as String,before: freezed == before ? _self._before : before // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,after: freezed == after ? _self._after : after // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,reason: freezed == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
