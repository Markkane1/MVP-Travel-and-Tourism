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
mixin _$Booking {

@JsonKey(includeToJson: false) String get id; String get userId; String get tourId; String get status; double get totalPrice; String? get bookingReferenceCode; bool get refunded; String? get refundReason; String? get adminNotes; String? get lastAdminActionBy; Map<String, dynamic>? get tourSnapshot; Map<String, dynamic>? get participantCounts; Map<String, dynamic>? get paymentReferences;@JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson) DateTime? get bookingDate;@JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson) DateTime? get refundedAt;@JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson) DateTime? get lastAdminActionAt;@JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson) DateTime? get createdAt;
/// Create a copy of Booking
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BookingCopyWith<Booking> get copyWith => _$BookingCopyWithImpl<Booking>(this as Booking, _$identity);

  /// Serializes this Booking to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Booking&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.tourId, tourId) || other.tourId == tourId)&&(identical(other.status, status) || other.status == status)&&(identical(other.totalPrice, totalPrice) || other.totalPrice == totalPrice)&&(identical(other.bookingReferenceCode, bookingReferenceCode) || other.bookingReferenceCode == bookingReferenceCode)&&(identical(other.refunded, refunded) || other.refunded == refunded)&&(identical(other.refundReason, refundReason) || other.refundReason == refundReason)&&(identical(other.adminNotes, adminNotes) || other.adminNotes == adminNotes)&&(identical(other.lastAdminActionBy, lastAdminActionBy) || other.lastAdminActionBy == lastAdminActionBy)&&const DeepCollectionEquality().equals(other.tourSnapshot, tourSnapshot)&&const DeepCollectionEquality().equals(other.participantCounts, participantCounts)&&const DeepCollectionEquality().equals(other.paymentReferences, paymentReferences)&&(identical(other.bookingDate, bookingDate) || other.bookingDate == bookingDate)&&(identical(other.refundedAt, refundedAt) || other.refundedAt == refundedAt)&&(identical(other.lastAdminActionAt, lastAdminActionAt) || other.lastAdminActionAt == lastAdminActionAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,tourId,status,totalPrice,bookingReferenceCode,refunded,refundReason,adminNotes,lastAdminActionBy,const DeepCollectionEquality().hash(tourSnapshot),const DeepCollectionEquality().hash(participantCounts),const DeepCollectionEquality().hash(paymentReferences),bookingDate,refundedAt,lastAdminActionAt,createdAt);

@override
String toString() {
  return 'Booking(id: $id, userId: $userId, tourId: $tourId, status: $status, totalPrice: $totalPrice, bookingReferenceCode: $bookingReferenceCode, refunded: $refunded, refundReason: $refundReason, adminNotes: $adminNotes, lastAdminActionBy: $lastAdminActionBy, tourSnapshot: $tourSnapshot, participantCounts: $participantCounts, paymentReferences: $paymentReferences, bookingDate: $bookingDate, refundedAt: $refundedAt, lastAdminActionAt: $lastAdminActionAt, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $BookingCopyWith<$Res>  {
  factory $BookingCopyWith(Booking value, $Res Function(Booking) _then) = _$BookingCopyWithImpl;
@useResult
$Res call({
@JsonKey(includeToJson: false) String id, String userId, String tourId, String status, double totalPrice, String? bookingReferenceCode, bool refunded, String? refundReason, String? adminNotes, String? lastAdminActionBy, Map<String, dynamic>? tourSnapshot, Map<String, dynamic>? participantCounts, Map<String, dynamic>? paymentReferences,@JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson) DateTime? bookingDate,@JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson) DateTime? refundedAt,@JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson) DateTime? lastAdminActionAt,@JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson) DateTime? createdAt
});




}
/// @nodoc
class _$BookingCopyWithImpl<$Res>
    implements $BookingCopyWith<$Res> {
  _$BookingCopyWithImpl(this._self, this._then);

  final Booking _self;
  final $Res Function(Booking) _then;

/// Create a copy of Booking
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? tourId = null,Object? status = null,Object? totalPrice = null,Object? bookingReferenceCode = freezed,Object? refunded = null,Object? refundReason = freezed,Object? adminNotes = freezed,Object? lastAdminActionBy = freezed,Object? tourSnapshot = freezed,Object? participantCounts = freezed,Object? paymentReferences = freezed,Object? bookingDate = freezed,Object? refundedAt = freezed,Object? lastAdminActionAt = freezed,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,tourId: null == tourId ? _self.tourId : tourId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,totalPrice: null == totalPrice ? _self.totalPrice : totalPrice // ignore: cast_nullable_to_non_nullable
as double,bookingReferenceCode: freezed == bookingReferenceCode ? _self.bookingReferenceCode : bookingReferenceCode // ignore: cast_nullable_to_non_nullable
as String?,refunded: null == refunded ? _self.refunded : refunded // ignore: cast_nullable_to_non_nullable
as bool,refundReason: freezed == refundReason ? _self.refundReason : refundReason // ignore: cast_nullable_to_non_nullable
as String?,adminNotes: freezed == adminNotes ? _self.adminNotes : adminNotes // ignore: cast_nullable_to_non_nullable
as String?,lastAdminActionBy: freezed == lastAdminActionBy ? _self.lastAdminActionBy : lastAdminActionBy // ignore: cast_nullable_to_non_nullable
as String?,tourSnapshot: freezed == tourSnapshot ? _self.tourSnapshot : tourSnapshot // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,participantCounts: freezed == participantCounts ? _self.participantCounts : participantCounts // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,paymentReferences: freezed == paymentReferences ? _self.paymentReferences : paymentReferences // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,bookingDate: freezed == bookingDate ? _self.bookingDate : bookingDate // ignore: cast_nullable_to_non_nullable
as DateTime?,refundedAt: freezed == refundedAt ? _self.refundedAt : refundedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,lastAdminActionAt: freezed == lastAdminActionAt ? _self.lastAdminActionAt : lastAdminActionAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(includeToJson: false)  String id,  String userId,  String tourId,  String status,  double totalPrice,  String? bookingReferenceCode,  bool refunded,  String? refundReason,  String? adminNotes,  String? lastAdminActionBy,  Map<String, dynamic>? tourSnapshot,  Map<String, dynamic>? participantCounts,  Map<String, dynamic>? paymentReferences, @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)  DateTime? bookingDate, @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)  DateTime? refundedAt, @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)  DateTime? lastAdminActionAt, @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Booking() when $default != null:
return $default(_that.id,_that.userId,_that.tourId,_that.status,_that.totalPrice,_that.bookingReferenceCode,_that.refunded,_that.refundReason,_that.adminNotes,_that.lastAdminActionBy,_that.tourSnapshot,_that.participantCounts,_that.paymentReferences,_that.bookingDate,_that.refundedAt,_that.lastAdminActionAt,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(includeToJson: false)  String id,  String userId,  String tourId,  String status,  double totalPrice,  String? bookingReferenceCode,  bool refunded,  String? refundReason,  String? adminNotes,  String? lastAdminActionBy,  Map<String, dynamic>? tourSnapshot,  Map<String, dynamic>? participantCounts,  Map<String, dynamic>? paymentReferences, @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)  DateTime? bookingDate, @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)  DateTime? refundedAt, @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)  DateTime? lastAdminActionAt, @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _Booking():
return $default(_that.id,_that.userId,_that.tourId,_that.status,_that.totalPrice,_that.bookingReferenceCode,_that.refunded,_that.refundReason,_that.adminNotes,_that.lastAdminActionBy,_that.tourSnapshot,_that.participantCounts,_that.paymentReferences,_that.bookingDate,_that.refundedAt,_that.lastAdminActionAt,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(includeToJson: false)  String id,  String userId,  String tourId,  String status,  double totalPrice,  String? bookingReferenceCode,  bool refunded,  String? refundReason,  String? adminNotes,  String? lastAdminActionBy,  Map<String, dynamic>? tourSnapshot,  Map<String, dynamic>? participantCounts,  Map<String, dynamic>? paymentReferences, @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)  DateTime? bookingDate, @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)  DateTime? refundedAt, @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)  DateTime? lastAdminActionAt, @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _Booking() when $default != null:
return $default(_that.id,_that.userId,_that.tourId,_that.status,_that.totalPrice,_that.bookingReferenceCode,_that.refunded,_that.refundReason,_that.adminNotes,_that.lastAdminActionBy,_that.tourSnapshot,_that.participantCounts,_that.paymentReferences,_that.bookingDate,_that.refundedAt,_that.lastAdminActionAt,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Booking extends Booking {
  const _Booking({@JsonKey(includeToJson: false) this.id = '', required this.userId, required this.tourId, required this.status, required this.totalPrice, this.bookingReferenceCode, this.refunded = false, this.refundReason, this.adminNotes, this.lastAdminActionBy, final  Map<String, dynamic>? tourSnapshot, final  Map<String, dynamic>? participantCounts, final  Map<String, dynamic>? paymentReferences, @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson) this.bookingDate, @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson) this.refundedAt, @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson) this.lastAdminActionAt, @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson) this.createdAt}): _tourSnapshot = tourSnapshot,_participantCounts = participantCounts,_paymentReferences = paymentReferences,super._();
  factory _Booking.fromJson(Map<String, dynamic> json) => _$BookingFromJson(json);

@override@JsonKey(includeToJson: false) final  String id;
@override final  String userId;
@override final  String tourId;
@override final  String status;
@override final  double totalPrice;
@override final  String? bookingReferenceCode;
@override@JsonKey() final  bool refunded;
@override final  String? refundReason;
@override final  String? adminNotes;
@override final  String? lastAdminActionBy;
 final  Map<String, dynamic>? _tourSnapshot;
@override Map<String, dynamic>? get tourSnapshot {
  final value = _tourSnapshot;
  if (value == null) return null;
  if (_tourSnapshot is EqualUnmodifiableMapView) return _tourSnapshot;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

 final  Map<String, dynamic>? _participantCounts;
@override Map<String, dynamic>? get participantCounts {
  final value = _participantCounts;
  if (value == null) return null;
  if (_participantCounts is EqualUnmodifiableMapView) return _participantCounts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

 final  Map<String, dynamic>? _paymentReferences;
@override Map<String, dynamic>? get paymentReferences {
  final value = _paymentReferences;
  if (value == null) return null;
  if (_paymentReferences is EqualUnmodifiableMapView) return _paymentReferences;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override@JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson) final  DateTime? bookingDate;
@override@JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson) final  DateTime? refundedAt;
@override@JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson) final  DateTime? lastAdminActionAt;
@override@JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson) final  DateTime? createdAt;

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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Booking&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.tourId, tourId) || other.tourId == tourId)&&(identical(other.status, status) || other.status == status)&&(identical(other.totalPrice, totalPrice) || other.totalPrice == totalPrice)&&(identical(other.bookingReferenceCode, bookingReferenceCode) || other.bookingReferenceCode == bookingReferenceCode)&&(identical(other.refunded, refunded) || other.refunded == refunded)&&(identical(other.refundReason, refundReason) || other.refundReason == refundReason)&&(identical(other.adminNotes, adminNotes) || other.adminNotes == adminNotes)&&(identical(other.lastAdminActionBy, lastAdminActionBy) || other.lastAdminActionBy == lastAdminActionBy)&&const DeepCollectionEquality().equals(other._tourSnapshot, _tourSnapshot)&&const DeepCollectionEquality().equals(other._participantCounts, _participantCounts)&&const DeepCollectionEquality().equals(other._paymentReferences, _paymentReferences)&&(identical(other.bookingDate, bookingDate) || other.bookingDate == bookingDate)&&(identical(other.refundedAt, refundedAt) || other.refundedAt == refundedAt)&&(identical(other.lastAdminActionAt, lastAdminActionAt) || other.lastAdminActionAt == lastAdminActionAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,tourId,status,totalPrice,bookingReferenceCode,refunded,refundReason,adminNotes,lastAdminActionBy,const DeepCollectionEquality().hash(_tourSnapshot),const DeepCollectionEquality().hash(_participantCounts),const DeepCollectionEquality().hash(_paymentReferences),bookingDate,refundedAt,lastAdminActionAt,createdAt);

@override
String toString() {
  return 'Booking(id: $id, userId: $userId, tourId: $tourId, status: $status, totalPrice: $totalPrice, bookingReferenceCode: $bookingReferenceCode, refunded: $refunded, refundReason: $refundReason, adminNotes: $adminNotes, lastAdminActionBy: $lastAdminActionBy, tourSnapshot: $tourSnapshot, participantCounts: $participantCounts, paymentReferences: $paymentReferences, bookingDate: $bookingDate, refundedAt: $refundedAt, lastAdminActionAt: $lastAdminActionAt, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$BookingCopyWith<$Res> implements $BookingCopyWith<$Res> {
  factory _$BookingCopyWith(_Booking value, $Res Function(_Booking) _then) = __$BookingCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(includeToJson: false) String id, String userId, String tourId, String status, double totalPrice, String? bookingReferenceCode, bool refunded, String? refundReason, String? adminNotes, String? lastAdminActionBy, Map<String, dynamic>? tourSnapshot, Map<String, dynamic>? participantCounts, Map<String, dynamic>? paymentReferences,@JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson) DateTime? bookingDate,@JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson) DateTime? refundedAt,@JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson) DateTime? lastAdminActionAt,@JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson) DateTime? createdAt
});




}
/// @nodoc
class __$BookingCopyWithImpl<$Res>
    implements _$BookingCopyWith<$Res> {
  __$BookingCopyWithImpl(this._self, this._then);

  final _Booking _self;
  final $Res Function(_Booking) _then;

/// Create a copy of Booking
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? tourId = null,Object? status = null,Object? totalPrice = null,Object? bookingReferenceCode = freezed,Object? refunded = null,Object? refundReason = freezed,Object? adminNotes = freezed,Object? lastAdminActionBy = freezed,Object? tourSnapshot = freezed,Object? participantCounts = freezed,Object? paymentReferences = freezed,Object? bookingDate = freezed,Object? refundedAt = freezed,Object? lastAdminActionAt = freezed,Object? createdAt = freezed,}) {
  return _then(_Booking(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,tourId: null == tourId ? _self.tourId : tourId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,totalPrice: null == totalPrice ? _self.totalPrice : totalPrice // ignore: cast_nullable_to_non_nullable
as double,bookingReferenceCode: freezed == bookingReferenceCode ? _self.bookingReferenceCode : bookingReferenceCode // ignore: cast_nullable_to_non_nullable
as String?,refunded: null == refunded ? _self.refunded : refunded // ignore: cast_nullable_to_non_nullable
as bool,refundReason: freezed == refundReason ? _self.refundReason : refundReason // ignore: cast_nullable_to_non_nullable
as String?,adminNotes: freezed == adminNotes ? _self.adminNotes : adminNotes // ignore: cast_nullable_to_non_nullable
as String?,lastAdminActionBy: freezed == lastAdminActionBy ? _self.lastAdminActionBy : lastAdminActionBy // ignore: cast_nullable_to_non_nullable
as String?,tourSnapshot: freezed == tourSnapshot ? _self._tourSnapshot : tourSnapshot // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,participantCounts: freezed == participantCounts ? _self._participantCounts : participantCounts // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,paymentReferences: freezed == paymentReferences ? _self._paymentReferences : paymentReferences // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,bookingDate: freezed == bookingDate ? _self.bookingDate : bookingDate // ignore: cast_nullable_to_non_nullable
as DateTime?,refundedAt: freezed == refundedAt ? _self.refundedAt : refundedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,lastAdminActionAt: freezed == lastAdminActionAt ? _self.lastAdminActionAt : lastAdminActionAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
