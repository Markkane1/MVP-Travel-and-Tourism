// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'staff_profile.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$StaffProfile {

 String get uid; String get email; String get role; bool get isActive;@JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson) DateTime? get updatedAt;
/// Create a copy of StaffProfile
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StaffProfileCopyWith<StaffProfile> get copyWith => _$StaffProfileCopyWithImpl<StaffProfile>(this as StaffProfile, _$identity);

  /// Serializes this StaffProfile to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StaffProfile&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.email, email) || other.email == email)&&(identical(other.role, role) || other.role == role)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,uid,email,role,isActive,updatedAt);

@override
String toString() {
  return 'StaffProfile(uid: $uid, email: $email, role: $role, isActive: $isActive, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $StaffProfileCopyWith<$Res>  {
  factory $StaffProfileCopyWith(StaffProfile value, $Res Function(StaffProfile) _then) = _$StaffProfileCopyWithImpl;
@useResult
$Res call({
 String uid, String email, String role, bool isActive,@JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson) DateTime? updatedAt
});




}
/// @nodoc
class _$StaffProfileCopyWithImpl<$Res>
    implements $StaffProfileCopyWith<$Res> {
  _$StaffProfileCopyWithImpl(this._self, this._then);

  final StaffProfile _self;
  final $Res Function(StaffProfile) _then;

/// Create a copy of StaffProfile
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? uid = null,Object? email = null,Object? role = null,Object? isActive = null,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [StaffProfile].
extension StaffProfilePatterns on StaffProfile {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StaffProfile value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StaffProfile() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StaffProfile value)  $default,){
final _that = this;
switch (_that) {
case _StaffProfile():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StaffProfile value)?  $default,){
final _that = this;
switch (_that) {
case _StaffProfile() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String uid,  String email,  String role,  bool isActive, @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StaffProfile() when $default != null:
return $default(_that.uid,_that.email,_that.role,_that.isActive,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String uid,  String email,  String role,  bool isActive, @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _StaffProfile():
return $default(_that.uid,_that.email,_that.role,_that.isActive,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String uid,  String email,  String role,  bool isActive, @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _StaffProfile() when $default != null:
return $default(_that.uid,_that.email,_that.role,_that.isActive,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _StaffProfile implements StaffProfile {
  const _StaffProfile({required this.uid, required this.email, required this.role, this.isActive = true, @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson) this.updatedAt});
  factory _StaffProfile.fromJson(Map<String, dynamic> json) => _$StaffProfileFromJson(json);

@override final  String uid;
@override final  String email;
@override final  String role;
@override@JsonKey() final  bool isActive;
@override@JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson) final  DateTime? updatedAt;

/// Create a copy of StaffProfile
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StaffProfileCopyWith<_StaffProfile> get copyWith => __$StaffProfileCopyWithImpl<_StaffProfile>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StaffProfileToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StaffProfile&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.email, email) || other.email == email)&&(identical(other.role, role) || other.role == role)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,uid,email,role,isActive,updatedAt);

@override
String toString() {
  return 'StaffProfile(uid: $uid, email: $email, role: $role, isActive: $isActive, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$StaffProfileCopyWith<$Res> implements $StaffProfileCopyWith<$Res> {
  factory _$StaffProfileCopyWith(_StaffProfile value, $Res Function(_StaffProfile) _then) = __$StaffProfileCopyWithImpl;
@override @useResult
$Res call({
 String uid, String email, String role, bool isActive,@JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson) DateTime? updatedAt
});




}
/// @nodoc
class __$StaffProfileCopyWithImpl<$Res>
    implements _$StaffProfileCopyWith<$Res> {
  __$StaffProfileCopyWithImpl(this._self, this._then);

  final _StaffProfile _self;
  final $Res Function(_StaffProfile) _then;

/// Create a copy of StaffProfile
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? uid = null,Object? email = null,Object? role = null,Object? isActive = null,Object? updatedAt = freezed,}) {
  return _then(_StaffProfile(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
