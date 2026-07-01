// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'booking.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TourSnapshot {

 String get title; String get heroImageUrl; String get destination;
/// Create a copy of TourSnapshot
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TourSnapshotCopyWith<TourSnapshot> get copyWith => _$TourSnapshotCopyWithImpl<TourSnapshot>(this as TourSnapshot, _$identity);

  /// Serializes this TourSnapshot to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TourSnapshot&&(identical(other.title, title) || other.title == title)&&(identical(other.heroImageUrl, heroImageUrl) || other.heroImageUrl == heroImageUrl)&&(identical(other.destination, destination) || other.destination == destination));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,title,heroImageUrl,destination);

@override
String toString() {
  return 'TourSnapshot(title: $title, heroImageUrl: $heroImageUrl, destination: $destination)';
}


}

/// @nodoc
abstract mixin class $TourSnapshotCopyWith<$Res>  {
  factory $TourSnapshotCopyWith(TourSnapshot value, $Res Function(TourSnapshot) _then) = _$TourSnapshotCopyWithImpl;
@useResult
$Res call({
 String title, String heroImageUrl, String destination
});




}
/// @nodoc
class _$TourSnapshotCopyWithImpl<$Res>
    implements $TourSnapshotCopyWith<$Res> {
  _$TourSnapshotCopyWithImpl(this._self, this._then);

  final TourSnapshot _self;
  final $Res Function(TourSnapshot) _then;

/// Create a copy of TourSnapshot
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? title = null,Object? heroImageUrl = null,Object? destination = null,}) {
  return _then(_self.copyWith(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,heroImageUrl: null == heroImageUrl ? _self.heroImageUrl : heroImageUrl // ignore: cast_nullable_to_non_nullable
as String,destination: null == destination ? _self.destination : destination // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [TourSnapshot].
extension TourSnapshotPatterns on TourSnapshot {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TourSnapshot value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TourSnapshot() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TourSnapshot value)  $default,){
final _that = this;
switch (_that) {
case _TourSnapshot():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TourSnapshot value)?  $default,){
final _that = this;
switch (_that) {
case _TourSnapshot() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String title,  String heroImageUrl,  String destination)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TourSnapshot() when $default != null:
return $default(_that.title,_that.heroImageUrl,_that.destination);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String title,  String heroImageUrl,  String destination)  $default,) {final _that = this;
switch (_that) {
case _TourSnapshot():
return $default(_that.title,_that.heroImageUrl,_that.destination);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String title,  String heroImageUrl,  String destination)?  $default,) {final _that = this;
switch (_that) {
case _TourSnapshot() when $default != null:
return $default(_that.title,_that.heroImageUrl,_that.destination);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TourSnapshot implements TourSnapshot {
  const _TourSnapshot({required this.title, required this.heroImageUrl, required this.destination});
  factory _TourSnapshot.fromJson(Map<String, dynamic> json) => _$TourSnapshotFromJson(json);

@override final  String title;
@override final  String heroImageUrl;
@override final  String destination;

/// Create a copy of TourSnapshot
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TourSnapshotCopyWith<_TourSnapshot> get copyWith => __$TourSnapshotCopyWithImpl<_TourSnapshot>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TourSnapshotToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TourSnapshot&&(identical(other.title, title) || other.title == title)&&(identical(other.heroImageUrl, heroImageUrl) || other.heroImageUrl == heroImageUrl)&&(identical(other.destination, destination) || other.destination == destination));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,title,heroImageUrl,destination);

@override
String toString() {
  return 'TourSnapshot(title: $title, heroImageUrl: $heroImageUrl, destination: $destination)';
}


}

/// @nodoc
abstract mixin class _$TourSnapshotCopyWith<$Res> implements $TourSnapshotCopyWith<$Res> {
  factory _$TourSnapshotCopyWith(_TourSnapshot value, $Res Function(_TourSnapshot) _then) = __$TourSnapshotCopyWithImpl;
@override @useResult
$Res call({
 String title, String heroImageUrl, String destination
});




}
/// @nodoc
class __$TourSnapshotCopyWithImpl<$Res>
    implements _$TourSnapshotCopyWith<$Res> {
  __$TourSnapshotCopyWithImpl(this._self, this._then);

  final _TourSnapshot _self;
  final $Res Function(_TourSnapshot) _then;

/// Create a copy of TourSnapshot
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? title = null,Object? heroImageUrl = null,Object? destination = null,}) {
  return _then(_TourSnapshot(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,heroImageUrl: null == heroImageUrl ? _self.heroImageUrl : heroImageUrl // ignore: cast_nullable_to_non_nullable
as String,destination: null == destination ? _self.destination : destination // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$Booking {

 String get id; String get userId; String get tourId; TourSnapshot get tourSnapshot; DateTime get tourDate; int get adults; int get children; bool get privateVehicle; String get groupSizeOption; String get pickupLocation; String? get specialRequests; double get totalPrice; String get currency; String get status; String? get stripePaymentIntentId; String? get bookingReferenceCode; bool get reviewed; DateTime get createdAt;
/// Create a copy of Booking
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BookingCopyWith<Booking> get copyWith => _$BookingCopyWithImpl<Booking>(this as Booking, _$identity);

  /// Serializes this Booking to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Booking&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.tourId, tourId) || other.tourId == tourId)&&(identical(other.tourSnapshot, tourSnapshot) || other.tourSnapshot == tourSnapshot)&&(identical(other.tourDate, tourDate) || other.tourDate == tourDate)&&(identical(other.adults, adults) || other.adults == adults)&&(identical(other.children, children) || other.children == children)&&(identical(other.privateVehicle, privateVehicle) || other.privateVehicle == privateVehicle)&&(identical(other.groupSizeOption, groupSizeOption) || other.groupSizeOption == groupSizeOption)&&(identical(other.pickupLocation, pickupLocation) || other.pickupLocation == pickupLocation)&&(identical(other.specialRequests, specialRequests) || other.specialRequests == specialRequests)&&(identical(other.totalPrice, totalPrice) || other.totalPrice == totalPrice)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.status, status) || other.status == status)&&(identical(other.stripePaymentIntentId, stripePaymentIntentId) || other.stripePaymentIntentId == stripePaymentIntentId)&&(identical(other.bookingReferenceCode, bookingReferenceCode) || other.bookingReferenceCode == bookingReferenceCode)&&(identical(other.reviewed, reviewed) || other.reviewed == reviewed)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,tourId,tourSnapshot,tourDate,adults,children,privateVehicle,groupSizeOption,pickupLocation,specialRequests,totalPrice,currency,status,stripePaymentIntentId,bookingReferenceCode,reviewed,createdAt);

@override
String toString() {
  return 'Booking(id: $id, userId: $userId, tourId: $tourId, tourSnapshot: $tourSnapshot, tourDate: $tourDate, adults: $adults, children: $children, privateVehicle: $privateVehicle, groupSizeOption: $groupSizeOption, pickupLocation: $pickupLocation, specialRequests: $specialRequests, totalPrice: $totalPrice, currency: $currency, status: $status, stripePaymentIntentId: $stripePaymentIntentId, bookingReferenceCode: $bookingReferenceCode, reviewed: $reviewed, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $BookingCopyWith<$Res>  {
  factory $BookingCopyWith(Booking value, $Res Function(Booking) _then) = _$BookingCopyWithImpl;
@useResult
$Res call({
 String id, String userId, String tourId, TourSnapshot tourSnapshot, DateTime tourDate, int adults, int children, bool privateVehicle, String groupSizeOption, String pickupLocation, String? specialRequests, double totalPrice, String currency, String status, String? stripePaymentIntentId, String? bookingReferenceCode, bool reviewed, DateTime createdAt
});


$TourSnapshotCopyWith<$Res> get tourSnapshot;

}
/// @nodoc
class _$BookingCopyWithImpl<$Res>
    implements $BookingCopyWith<$Res> {
  _$BookingCopyWithImpl(this._self, this._then);

  final Booking _self;
  final $Res Function(Booking) _then;

/// Create a copy of Booking
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? tourId = null,Object? tourSnapshot = null,Object? tourDate = null,Object? adults = null,Object? children = null,Object? privateVehicle = null,Object? groupSizeOption = null,Object? pickupLocation = null,Object? specialRequests = freezed,Object? totalPrice = null,Object? currency = null,Object? status = null,Object? stripePaymentIntentId = freezed,Object? bookingReferenceCode = freezed,Object? reviewed = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,tourId: null == tourId ? _self.tourId : tourId // ignore: cast_nullable_to_non_nullable
as String,tourSnapshot: null == tourSnapshot ? _self.tourSnapshot : tourSnapshot // ignore: cast_nullable_to_non_nullable
as TourSnapshot,tourDate: null == tourDate ? _self.tourDate : tourDate // ignore: cast_nullable_to_non_nullable
as DateTime,adults: null == adults ? _self.adults : adults // ignore: cast_nullable_to_non_nullable
as int,children: null == children ? _self.children : children // ignore: cast_nullable_to_non_nullable
as int,privateVehicle: null == privateVehicle ? _self.privateVehicle : privateVehicle // ignore: cast_nullable_to_non_nullable
as bool,groupSizeOption: null == groupSizeOption ? _self.groupSizeOption : groupSizeOption // ignore: cast_nullable_to_non_nullable
as String,pickupLocation: null == pickupLocation ? _self.pickupLocation : pickupLocation // ignore: cast_nullable_to_non_nullable
as String,specialRequests: freezed == specialRequests ? _self.specialRequests : specialRequests // ignore: cast_nullable_to_non_nullable
as String?,totalPrice: null == totalPrice ? _self.totalPrice : totalPrice // ignore: cast_nullable_to_non_nullable
as double,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,stripePaymentIntentId: freezed == stripePaymentIntentId ? _self.stripePaymentIntentId : stripePaymentIntentId // ignore: cast_nullable_to_non_nullable
as String?,bookingReferenceCode: freezed == bookingReferenceCode ? _self.bookingReferenceCode : bookingReferenceCode // ignore: cast_nullable_to_non_nullable
as String?,reviewed: null == reviewed ? _self.reviewed : reviewed // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}
/// Create a copy of Booking
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TourSnapshotCopyWith<$Res> get tourSnapshot {
  
  return $TourSnapshotCopyWith<$Res>(_self.tourSnapshot, (value) {
    return _then(_self.copyWith(tourSnapshot: value));
  });
}
}


/// Adds pattern-matching-related methods to [Booking].
extension BookingPatterns on Booking {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Booking value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Booking() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Booking value)  $default,){
final _that = this;
switch (_that) {
case _Booking():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Booking value)?  $default,){
final _that = this;
switch (_that) {
case _Booking() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String userId,  String tourId,  TourSnapshot tourSnapshot,  DateTime tourDate,  int adults,  int children,  bool privateVehicle,  String groupSizeOption,  String pickupLocation,  String? specialRequests,  double totalPrice,  String currency,  String status,  String? stripePaymentIntentId,  String? bookingReferenceCode,  bool reviewed,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Booking() when $default != null:
return $default(_that.id,_that.userId,_that.tourId,_that.tourSnapshot,_that.tourDate,_that.adults,_that.children,_that.privateVehicle,_that.groupSizeOption,_that.pickupLocation,_that.specialRequests,_that.totalPrice,_that.currency,_that.status,_that.stripePaymentIntentId,_that.bookingReferenceCode,_that.reviewed,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String userId,  String tourId,  TourSnapshot tourSnapshot,  DateTime tourDate,  int adults,  int children,  bool privateVehicle,  String groupSizeOption,  String pickupLocation,  String? specialRequests,  double totalPrice,  String currency,  String status,  String? stripePaymentIntentId,  String? bookingReferenceCode,  bool reviewed,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _Booking():
return $default(_that.id,_that.userId,_that.tourId,_that.tourSnapshot,_that.tourDate,_that.adults,_that.children,_that.privateVehicle,_that.groupSizeOption,_that.pickupLocation,_that.specialRequests,_that.totalPrice,_that.currency,_that.status,_that.stripePaymentIntentId,_that.bookingReferenceCode,_that.reviewed,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String userId,  String tourId,  TourSnapshot tourSnapshot,  DateTime tourDate,  int adults,  int children,  bool privateVehicle,  String groupSizeOption,  String pickupLocation,  String? specialRequests,  double totalPrice,  String currency,  String status,  String? stripePaymentIntentId,  String? bookingReferenceCode,  bool reviewed,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _Booking() when $default != null:
return $default(_that.id,_that.userId,_that.tourId,_that.tourSnapshot,_that.tourDate,_that.adults,_that.children,_that.privateVehicle,_that.groupSizeOption,_that.pickupLocation,_that.specialRequests,_that.totalPrice,_that.currency,_that.status,_that.stripePaymentIntentId,_that.bookingReferenceCode,_that.reviewed,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Booking implements Booking {
  const _Booking({required this.id, required this.userId, required this.tourId, required this.tourSnapshot, required this.tourDate, required this.adults, required this.children, required this.privateVehicle, required this.groupSizeOption, required this.pickupLocation, this.specialRequests, required this.totalPrice, required this.currency, required this.status, this.stripePaymentIntentId, this.bookingReferenceCode, this.reviewed = false, required this.createdAt});
  factory _Booking.fromJson(Map<String, dynamic> json) => _$BookingFromJson(json);

@override final  String id;
@override final  String userId;
@override final  String tourId;
@override final  TourSnapshot tourSnapshot;
@override final  DateTime tourDate;
@override final  int adults;
@override final  int children;
@override final  bool privateVehicle;
@override final  String groupSizeOption;
@override final  String pickupLocation;
@override final  String? specialRequests;
@override final  double totalPrice;
@override final  String currency;
@override final  String status;
@override final  String? stripePaymentIntentId;
@override final  String? bookingReferenceCode;
@override@JsonKey() final  bool reviewed;
@override final  DateTime createdAt;

/// Create a copy of Booking
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BookingCopyWith<_Booking> get copyWith => __$BookingCopyWithImpl<_Booking>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BookingToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Booking&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.tourId, tourId) || other.tourId == tourId)&&(identical(other.tourSnapshot, tourSnapshot) || other.tourSnapshot == tourSnapshot)&&(identical(other.tourDate, tourDate) || other.tourDate == tourDate)&&(identical(other.adults, adults) || other.adults == adults)&&(identical(other.children, children) || other.children == children)&&(identical(other.privateVehicle, privateVehicle) || other.privateVehicle == privateVehicle)&&(identical(other.groupSizeOption, groupSizeOption) || other.groupSizeOption == groupSizeOption)&&(identical(other.pickupLocation, pickupLocation) || other.pickupLocation == pickupLocation)&&(identical(other.specialRequests, specialRequests) || other.specialRequests == specialRequests)&&(identical(other.totalPrice, totalPrice) || other.totalPrice == totalPrice)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.status, status) || other.status == status)&&(identical(other.stripePaymentIntentId, stripePaymentIntentId) || other.stripePaymentIntentId == stripePaymentIntentId)&&(identical(other.bookingReferenceCode, bookingReferenceCode) || other.bookingReferenceCode == bookingReferenceCode)&&(identical(other.reviewed, reviewed) || other.reviewed == reviewed)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,tourId,tourSnapshot,tourDate,adults,children,privateVehicle,groupSizeOption,pickupLocation,specialRequests,totalPrice,currency,status,stripePaymentIntentId,bookingReferenceCode,reviewed,createdAt);

@override
String toString() {
  return 'Booking(id: $id, userId: $userId, tourId: $tourId, tourSnapshot: $tourSnapshot, tourDate: $tourDate, adults: $adults, children: $children, privateVehicle: $privateVehicle, groupSizeOption: $groupSizeOption, pickupLocation: $pickupLocation, specialRequests: $specialRequests, totalPrice: $totalPrice, currency: $currency, status: $status, stripePaymentIntentId: $stripePaymentIntentId, bookingReferenceCode: $bookingReferenceCode, reviewed: $reviewed, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$BookingCopyWith<$Res> implements $BookingCopyWith<$Res> {
  factory _$BookingCopyWith(_Booking value, $Res Function(_Booking) _then) = __$BookingCopyWithImpl;
@override @useResult
$Res call({
 String id, String userId, String tourId, TourSnapshot tourSnapshot, DateTime tourDate, int adults, int children, bool privateVehicle, String groupSizeOption, String pickupLocation, String? specialRequests, double totalPrice, String currency, String status, String? stripePaymentIntentId, String? bookingReferenceCode, bool reviewed, DateTime createdAt
});


@override $TourSnapshotCopyWith<$Res> get tourSnapshot;

}
/// @nodoc
class __$BookingCopyWithImpl<$Res>
    implements _$BookingCopyWith<$Res> {
  __$BookingCopyWithImpl(this._self, this._then);

  final _Booking _self;
  final $Res Function(_Booking) _then;

/// Create a copy of Booking
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? tourId = null,Object? tourSnapshot = null,Object? tourDate = null,Object? adults = null,Object? children = null,Object? privateVehicle = null,Object? groupSizeOption = null,Object? pickupLocation = null,Object? specialRequests = freezed,Object? totalPrice = null,Object? currency = null,Object? status = null,Object? stripePaymentIntentId = freezed,Object? bookingReferenceCode = freezed,Object? reviewed = null,Object? createdAt = null,}) {
  return _then(_Booking(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,tourId: null == tourId ? _self.tourId : tourId // ignore: cast_nullable_to_non_nullable
as String,tourSnapshot: null == tourSnapshot ? _self.tourSnapshot : tourSnapshot // ignore: cast_nullable_to_non_nullable
as TourSnapshot,tourDate: null == tourDate ? _self.tourDate : tourDate // ignore: cast_nullable_to_non_nullable
as DateTime,adults: null == adults ? _self.adults : adults // ignore: cast_nullable_to_non_nullable
as int,children: null == children ? _self.children : children // ignore: cast_nullable_to_non_nullable
as int,privateVehicle: null == privateVehicle ? _self.privateVehicle : privateVehicle // ignore: cast_nullable_to_non_nullable
as bool,groupSizeOption: null == groupSizeOption ? _self.groupSizeOption : groupSizeOption // ignore: cast_nullable_to_non_nullable
as String,pickupLocation: null == pickupLocation ? _self.pickupLocation : pickupLocation // ignore: cast_nullable_to_non_nullable
as String,specialRequests: freezed == specialRequests ? _self.specialRequests : specialRequests // ignore: cast_nullable_to_non_nullable
as String?,totalPrice: null == totalPrice ? _self.totalPrice : totalPrice // ignore: cast_nullable_to_non_nullable
as double,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,stripePaymentIntentId: freezed == stripePaymentIntentId ? _self.stripePaymentIntentId : stripePaymentIntentId // ignore: cast_nullable_to_non_nullable
as String?,bookingReferenceCode: freezed == bookingReferenceCode ? _self.bookingReferenceCode : bookingReferenceCode // ignore: cast_nullable_to_non_nullable
as String?,reviewed: null == reviewed ? _self.reviewed : reviewed // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

/// Create a copy of Booking
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TourSnapshotCopyWith<$Res> get tourSnapshot {
  
  return $TourSnapshotCopyWith<$Res>(_self.tourSnapshot, (value) {
    return _then(_self.copyWith(tourSnapshot: value));
  });
}
}

// dart format on
