// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UserModel {

@JsonKey(includeToJson: false) String get id; String get email; String? get displayName; String get tier; int get loyaltyPoints; String? get conciergeId; Map<String, dynamic>? get preferences; List<String> get savedTours;@JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson) DateTime? get createdAt;
/// Create a copy of UserModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserModelCopyWith<UserModel> get copyWith => _$UserModelCopyWithImpl<UserModel>(this as UserModel, _$identity);

  /// Serializes this UserModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserModel&&(identical(other.id, id) || other.id == id)&&(identical(other.email, email) || other.email == email)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.tier, tier) || other.tier == tier)&&(identical(other.loyaltyPoints, loyaltyPoints) || other.loyaltyPoints == loyaltyPoints)&&(identical(other.conciergeId, conciergeId) || other.conciergeId == conciergeId)&&const DeepCollectionEquality().equals(other.preferences, preferences)&&const DeepCollectionEquality().equals(other.savedTours, savedTours)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,email,displayName,tier,loyaltyPoints,conciergeId,const DeepCollectionEquality().hash(preferences),const DeepCollectionEquality().hash(savedTours),createdAt);

@override
String toString() {
  return 'UserModel(id: $id, email: $email, displayName: $displayName, tier: $tier, loyaltyPoints: $loyaltyPoints, conciergeId: $conciergeId, preferences: $preferences, savedTours: $savedTours, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $UserModelCopyWith<$Res>  {
  factory $UserModelCopyWith(UserModel value, $Res Function(UserModel) _then) = _$UserModelCopyWithImpl;
@useResult
$Res call({
@JsonKey(includeToJson: false) String id, String email, String? displayName, String tier, int loyaltyPoints, String? conciergeId, Map<String, dynamic>? preferences, List<String> savedTours,@JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson) DateTime? createdAt
});




}
/// @nodoc
class _$UserModelCopyWithImpl<$Res>
    implements $UserModelCopyWith<$Res> {
  _$UserModelCopyWithImpl(this._self, this._then);

  final UserModel _self;
  final $Res Function(UserModel) _then;

/// Create a copy of UserModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? email = null,Object? displayName = freezed,Object? tier = null,Object? loyaltyPoints = null,Object? conciergeId = freezed,Object? preferences = freezed,Object? savedTours = null,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,tier: null == tier ? _self.tier : tier // ignore: cast_nullable_to_non_nullable
as String,loyaltyPoints: null == loyaltyPoints ? _self.loyaltyPoints : loyaltyPoints // ignore: cast_nullable_to_non_nullable
as int,conciergeId: freezed == conciergeId ? _self.conciergeId : conciergeId // ignore: cast_nullable_to_non_nullable
as String?,preferences: freezed == preferences ? _self.preferences : preferences // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,savedTours: null == savedTours ? _self.savedTours : savedTours // ignore: cast_nullable_to_non_nullable
as List<String>,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [UserModel].
extension UserModelPatterns on UserModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserModel value)  $default,){
final _that = this;
switch (_that) {
case _UserModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserModel value)?  $default,){
final _that = this;
switch (_that) {
case _UserModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(includeToJson: false)  String id,  String email,  String? displayName,  String tier,  int loyaltyPoints,  String? conciergeId,  Map<String, dynamic>? preferences,  List<String> savedTours, @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserModel() when $default != null:
return $default(_that.id,_that.email,_that.displayName,_that.tier,_that.loyaltyPoints,_that.conciergeId,_that.preferences,_that.savedTours,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(includeToJson: false)  String id,  String email,  String? displayName,  String tier,  int loyaltyPoints,  String? conciergeId,  Map<String, dynamic>? preferences,  List<String> savedTours, @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _UserModel():
return $default(_that.id,_that.email,_that.displayName,_that.tier,_that.loyaltyPoints,_that.conciergeId,_that.preferences,_that.savedTours,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(includeToJson: false)  String id,  String email,  String? displayName,  String tier,  int loyaltyPoints,  String? conciergeId,  Map<String, dynamic>? preferences,  List<String> savedTours, @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _UserModel() when $default != null:
return $default(_that.id,_that.email,_that.displayName,_that.tier,_that.loyaltyPoints,_that.conciergeId,_that.preferences,_that.savedTours,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UserModel extends UserModel {
  const _UserModel({@JsonKey(includeToJson: false) this.id = '', this.email = '', this.displayName, this.tier = 'base', this.loyaltyPoints = 0, this.conciergeId, final  Map<String, dynamic>? preferences, final  List<String> savedTours = const [], @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson) this.createdAt}): _preferences = preferences,_savedTours = savedTours,super._();
  factory _UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);

@override@JsonKey(includeToJson: false) final  String id;
@override@JsonKey() final  String email;
@override final  String? displayName;
@override@JsonKey() final  String tier;
@override@JsonKey() final  int loyaltyPoints;
@override final  String? conciergeId;
 final  Map<String, dynamic>? _preferences;
@override Map<String, dynamic>? get preferences {
  final value = _preferences;
  if (value == null) return null;
  if (_preferences is EqualUnmodifiableMapView) return _preferences;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

 final  List<String> _savedTours;
@override@JsonKey() List<String> get savedTours {
  if (_savedTours is EqualUnmodifiableListView) return _savedTours;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_savedTours);
}

@override@JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson) final  DateTime? createdAt;

/// Create a copy of UserModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserModelCopyWith<_UserModel> get copyWith => __$UserModelCopyWithImpl<_UserModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserModel&&(identical(other.id, id) || other.id == id)&&(identical(other.email, email) || other.email == email)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.tier, tier) || other.tier == tier)&&(identical(other.loyaltyPoints, loyaltyPoints) || other.loyaltyPoints == loyaltyPoints)&&(identical(other.conciergeId, conciergeId) || other.conciergeId == conciergeId)&&const DeepCollectionEquality().equals(other._preferences, _preferences)&&const DeepCollectionEquality().equals(other._savedTours, _savedTours)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,email,displayName,tier,loyaltyPoints,conciergeId,const DeepCollectionEquality().hash(_preferences),const DeepCollectionEquality().hash(_savedTours),createdAt);

@override
String toString() {
  return 'UserModel(id: $id, email: $email, displayName: $displayName, tier: $tier, loyaltyPoints: $loyaltyPoints, conciergeId: $conciergeId, preferences: $preferences, savedTours: $savedTours, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$UserModelCopyWith<$Res> implements $UserModelCopyWith<$Res> {
  factory _$UserModelCopyWith(_UserModel value, $Res Function(_UserModel) _then) = __$UserModelCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(includeToJson: false) String id, String email, String? displayName, String tier, int loyaltyPoints, String? conciergeId, Map<String, dynamic>? preferences, List<String> savedTours,@JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson) DateTime? createdAt
});




}
/// @nodoc
class __$UserModelCopyWithImpl<$Res>
    implements _$UserModelCopyWith<$Res> {
  __$UserModelCopyWithImpl(this._self, this._then);

  final _UserModel _self;
  final $Res Function(_UserModel) _then;

/// Create a copy of UserModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? email = null,Object? displayName = freezed,Object? tier = null,Object? loyaltyPoints = null,Object? conciergeId = freezed,Object? preferences = freezed,Object? savedTours = null,Object? createdAt = freezed,}) {
  return _then(_UserModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,tier: null == tier ? _self.tier : tier // ignore: cast_nullable_to_non_nullable
as String,loyaltyPoints: null == loyaltyPoints ? _self.loyaltyPoints : loyaltyPoints // ignore: cast_nullable_to_non_nullable
as int,conciergeId: freezed == conciergeId ? _self.conciergeId : conciergeId // ignore: cast_nullable_to_non_nullable
as String?,preferences: freezed == preferences ? _self._preferences : preferences // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,savedTours: null == savedTours ? _self._savedTours : savedTours // ignore: cast_nullable_to_non_nullable
as List<String>,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
