// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'service.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Service {

@JsonKey(includeToJson: false) String get id; String get name; String get category; String get description; double get basePrice; String get currency; String get unitType; String? get imageUrl; bool get isActive; int get sortOrder;@JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson) DateTime? get createdAt;@JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson) DateTime? get updatedAt;@JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson) DateTime? get archivedAt; String? get archivedBy;
/// Create a copy of Service
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ServiceCopyWith<Service> get copyWith => _$ServiceCopyWithImpl<Service>(this as Service, _$identity);

  /// Serializes this Service to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Service&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.category, category) || other.category == category)&&(identical(other.description, description) || other.description == description)&&(identical(other.basePrice, basePrice) || other.basePrice == basePrice)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.unitType, unitType) || other.unitType == unitType)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.archivedAt, archivedAt) || other.archivedAt == archivedAt)&&(identical(other.archivedBy, archivedBy) || other.archivedBy == archivedBy));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,category,description,basePrice,currency,unitType,imageUrl,isActive,sortOrder,createdAt,updatedAt,archivedAt,archivedBy);

@override
String toString() {
  return 'Service(id: $id, name: $name, category: $category, description: $description, basePrice: $basePrice, currency: $currency, unitType: $unitType, imageUrl: $imageUrl, isActive: $isActive, sortOrder: $sortOrder, createdAt: $createdAt, updatedAt: $updatedAt, archivedAt: $archivedAt, archivedBy: $archivedBy)';
}


}

/// @nodoc
abstract mixin class $ServiceCopyWith<$Res>  {
  factory $ServiceCopyWith(Service value, $Res Function(Service) _then) = _$ServiceCopyWithImpl;
@useResult
$Res call({
@JsonKey(includeToJson: false) String id, String name, String category, String description, double basePrice, String currency, String unitType, String? imageUrl, bool isActive, int sortOrder,@JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson) DateTime? createdAt,@JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson) DateTime? updatedAt,@JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson) DateTime? archivedAt, String? archivedBy
});




}
/// @nodoc
class _$ServiceCopyWithImpl<$Res>
    implements $ServiceCopyWith<$Res> {
  _$ServiceCopyWithImpl(this._self, this._then);

  final Service _self;
  final $Res Function(Service) _then;

/// Create a copy of Service
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? category = null,Object? description = null,Object? basePrice = null,Object? currency = null,Object? unitType = null,Object? imageUrl = freezed,Object? isActive = null,Object? sortOrder = null,Object? createdAt = freezed,Object? updatedAt = freezed,Object? archivedAt = freezed,Object? archivedBy = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,basePrice: null == basePrice ? _self.basePrice : basePrice // ignore: cast_nullable_to_non_nullable
as double,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,unitType: null == unitType ? _self.unitType : unitType // ignore: cast_nullable_to_non_nullable
as String,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,archivedAt: freezed == archivedAt ? _self.archivedAt : archivedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,archivedBy: freezed == archivedBy ? _self.archivedBy : archivedBy // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Service].
extension ServicePatterns on Service {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Service value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Service() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Service value)  $default,){
final _that = this;
switch (_that) {
case _Service():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Service value)?  $default,){
final _that = this;
switch (_that) {
case _Service() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(includeToJson: false)  String id,  String name,  String category,  String description,  double basePrice,  String currency,  String unitType,  String? imageUrl,  bool isActive,  int sortOrder, @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)  DateTime? createdAt, @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)  DateTime? updatedAt, @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)  DateTime? archivedAt,  String? archivedBy)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Service() when $default != null:
return $default(_that.id,_that.name,_that.category,_that.description,_that.basePrice,_that.currency,_that.unitType,_that.imageUrl,_that.isActive,_that.sortOrder,_that.createdAt,_that.updatedAt,_that.archivedAt,_that.archivedBy);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(includeToJson: false)  String id,  String name,  String category,  String description,  double basePrice,  String currency,  String unitType,  String? imageUrl,  bool isActive,  int sortOrder, @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)  DateTime? createdAt, @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)  DateTime? updatedAt, @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)  DateTime? archivedAt,  String? archivedBy)  $default,) {final _that = this;
switch (_that) {
case _Service():
return $default(_that.id,_that.name,_that.category,_that.description,_that.basePrice,_that.currency,_that.unitType,_that.imageUrl,_that.isActive,_that.sortOrder,_that.createdAt,_that.updatedAt,_that.archivedAt,_that.archivedBy);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(includeToJson: false)  String id,  String name,  String category,  String description,  double basePrice,  String currency,  String unitType,  String? imageUrl,  bool isActive,  int sortOrder, @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)  DateTime? createdAt, @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)  DateTime? updatedAt, @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)  DateTime? archivedAt,  String? archivedBy)?  $default,) {final _that = this;
switch (_that) {
case _Service() when $default != null:
return $default(_that.id,_that.name,_that.category,_that.description,_that.basePrice,_that.currency,_that.unitType,_that.imageUrl,_that.isActive,_that.sortOrder,_that.createdAt,_that.updatedAt,_that.archivedAt,_that.archivedBy);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Service extends Service {
  const _Service({@JsonKey(includeToJson: false) this.id = '', required this.name, required this.category, required this.description, required this.basePrice, required this.currency, required this.unitType, this.imageUrl, this.isActive = true, this.sortOrder = 0, @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson) this.createdAt, @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson) this.updatedAt, @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson) this.archivedAt, this.archivedBy}): super._();
  factory _Service.fromJson(Map<String, dynamic> json) => _$ServiceFromJson(json);

@override@JsonKey(includeToJson: false) final  String id;
@override final  String name;
@override final  String category;
@override final  String description;
@override final  double basePrice;
@override final  String currency;
@override final  String unitType;
@override final  String? imageUrl;
@override@JsonKey() final  bool isActive;
@override@JsonKey() final  int sortOrder;
@override@JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson) final  DateTime? createdAt;
@override@JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson) final  DateTime? updatedAt;
@override@JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson) final  DateTime? archivedAt;
@override final  String? archivedBy;

/// Create a copy of Service
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ServiceCopyWith<_Service> get copyWith => __$ServiceCopyWithImpl<_Service>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ServiceToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Service&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.category, category) || other.category == category)&&(identical(other.description, description) || other.description == description)&&(identical(other.basePrice, basePrice) || other.basePrice == basePrice)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.unitType, unitType) || other.unitType == unitType)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.archivedAt, archivedAt) || other.archivedAt == archivedAt)&&(identical(other.archivedBy, archivedBy) || other.archivedBy == archivedBy));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,category,description,basePrice,currency,unitType,imageUrl,isActive,sortOrder,createdAt,updatedAt,archivedAt,archivedBy);

@override
String toString() {
  return 'Service(id: $id, name: $name, category: $category, description: $description, basePrice: $basePrice, currency: $currency, unitType: $unitType, imageUrl: $imageUrl, isActive: $isActive, sortOrder: $sortOrder, createdAt: $createdAt, updatedAt: $updatedAt, archivedAt: $archivedAt, archivedBy: $archivedBy)';
}


}

/// @nodoc
abstract mixin class _$ServiceCopyWith<$Res> implements $ServiceCopyWith<$Res> {
  factory _$ServiceCopyWith(_Service value, $Res Function(_Service) _then) = __$ServiceCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(includeToJson: false) String id, String name, String category, String description, double basePrice, String currency, String unitType, String? imageUrl, bool isActive, int sortOrder,@JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson) DateTime? createdAt,@JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson) DateTime? updatedAt,@JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson) DateTime? archivedAt, String? archivedBy
});




}
/// @nodoc
class __$ServiceCopyWithImpl<$Res>
    implements _$ServiceCopyWith<$Res> {
  __$ServiceCopyWithImpl(this._self, this._then);

  final _Service _self;
  final $Res Function(_Service) _then;

/// Create a copy of Service
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? category = null,Object? description = null,Object? basePrice = null,Object? currency = null,Object? unitType = null,Object? imageUrl = freezed,Object? isActive = null,Object? sortOrder = null,Object? createdAt = freezed,Object? updatedAt = freezed,Object? archivedAt = freezed,Object? archivedBy = freezed,}) {
  return _then(_Service(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,basePrice: null == basePrice ? _self.basePrice : basePrice // ignore: cast_nullable_to_non_nullable
as double,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,unitType: null == unitType ? _self.unitType : unitType // ignore: cast_nullable_to_non_nullable
as String,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,archivedAt: freezed == archivedAt ? _self.archivedAt : archivedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,archivedBy: freezed == archivedBy ? _self.archivedBy : archivedBy // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
