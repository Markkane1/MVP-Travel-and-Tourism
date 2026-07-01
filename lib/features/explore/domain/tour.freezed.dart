// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tour.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Tour {

 String get id; String get title; String get destination; String get category; List<String> get badges; String get heroImageUrl; List<String> get galleryImageUrls; double get pricePerPerson; String get currency; int get durationDays; int get maxParticipants; double get ratingAverage; int get ratingCount; String get overview; List<Map<String, dynamic>> get itinerary; List<String> get inclusions; double get latitude; double get longitude; List<DateTime> get availableDates; double get privateVehicleSurcharge; List<Map<String, dynamic>> get groupSizeOptions;
/// Create a copy of Tour
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TourCopyWith<Tour> get copyWith => _$TourCopyWithImpl<Tour>(this as Tour, _$identity);

  /// Serializes this Tour to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Tour&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.destination, destination) || other.destination == destination)&&(identical(other.category, category) || other.category == category)&&const DeepCollectionEquality().equals(other.badges, badges)&&(identical(other.heroImageUrl, heroImageUrl) || other.heroImageUrl == heroImageUrl)&&const DeepCollectionEquality().equals(other.galleryImageUrls, galleryImageUrls)&&(identical(other.pricePerPerson, pricePerPerson) || other.pricePerPerson == pricePerPerson)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.durationDays, durationDays) || other.durationDays == durationDays)&&(identical(other.maxParticipants, maxParticipants) || other.maxParticipants == maxParticipants)&&(identical(other.ratingAverage, ratingAverage) || other.ratingAverage == ratingAverage)&&(identical(other.ratingCount, ratingCount) || other.ratingCount == ratingCount)&&(identical(other.overview, overview) || other.overview == overview)&&const DeepCollectionEquality().equals(other.itinerary, itinerary)&&const DeepCollectionEquality().equals(other.inclusions, inclusions)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&const DeepCollectionEquality().equals(other.availableDates, availableDates)&&(identical(other.privateVehicleSurcharge, privateVehicleSurcharge) || other.privateVehicleSurcharge == privateVehicleSurcharge)&&const DeepCollectionEquality().equals(other.groupSizeOptions, groupSizeOptions));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,title,destination,category,const DeepCollectionEquality().hash(badges),heroImageUrl,const DeepCollectionEquality().hash(galleryImageUrls),pricePerPerson,currency,durationDays,maxParticipants,ratingAverage,ratingCount,overview,const DeepCollectionEquality().hash(itinerary),const DeepCollectionEquality().hash(inclusions),latitude,longitude,const DeepCollectionEquality().hash(availableDates),privateVehicleSurcharge,const DeepCollectionEquality().hash(groupSizeOptions)]);

@override
String toString() {
  return 'Tour(id: $id, title: $title, destination: $destination, category: $category, badges: $badges, heroImageUrl: $heroImageUrl, galleryImageUrls: $galleryImageUrls, pricePerPerson: $pricePerPerson, currency: $currency, durationDays: $durationDays, maxParticipants: $maxParticipants, ratingAverage: $ratingAverage, ratingCount: $ratingCount, overview: $overview, itinerary: $itinerary, inclusions: $inclusions, latitude: $latitude, longitude: $longitude, availableDates: $availableDates, privateVehicleSurcharge: $privateVehicleSurcharge, groupSizeOptions: $groupSizeOptions)';
}


}

/// @nodoc
abstract mixin class $TourCopyWith<$Res>  {
  factory $TourCopyWith(Tour value, $Res Function(Tour) _then) = _$TourCopyWithImpl;
@useResult
$Res call({
 String id, String title, String destination, String category, List<String> badges, String heroImageUrl, List<String> galleryImageUrls, double pricePerPerson, String currency, int durationDays, int maxParticipants, double ratingAverage, int ratingCount, String overview, List<Map<String, dynamic>> itinerary, List<String> inclusions, double latitude, double longitude, List<DateTime> availableDates, double privateVehicleSurcharge, List<Map<String, dynamic>> groupSizeOptions
});




}
/// @nodoc
class _$TourCopyWithImpl<$Res>
    implements $TourCopyWith<$Res> {
  _$TourCopyWithImpl(this._self, this._then);

  final Tour _self;
  final $Res Function(Tour) _then;

/// Create a copy of Tour
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? destination = null,Object? category = null,Object? badges = null,Object? heroImageUrl = null,Object? galleryImageUrls = null,Object? pricePerPerson = null,Object? currency = null,Object? durationDays = null,Object? maxParticipants = null,Object? ratingAverage = null,Object? ratingCount = null,Object? overview = null,Object? itinerary = null,Object? inclusions = null,Object? latitude = null,Object? longitude = null,Object? availableDates = null,Object? privateVehicleSurcharge = null,Object? groupSizeOptions = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,destination: null == destination ? _self.destination : destination // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,badges: null == badges ? _self.badges : badges // ignore: cast_nullable_to_non_nullable
as List<String>,heroImageUrl: null == heroImageUrl ? _self.heroImageUrl : heroImageUrl // ignore: cast_nullable_to_non_nullable
as String,galleryImageUrls: null == galleryImageUrls ? _self.galleryImageUrls : galleryImageUrls // ignore: cast_nullable_to_non_nullable
as List<String>,pricePerPerson: null == pricePerPerson ? _self.pricePerPerson : pricePerPerson // ignore: cast_nullable_to_non_nullable
as double,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,durationDays: null == durationDays ? _self.durationDays : durationDays // ignore: cast_nullable_to_non_nullable
as int,maxParticipants: null == maxParticipants ? _self.maxParticipants : maxParticipants // ignore: cast_nullable_to_non_nullable
as int,ratingAverage: null == ratingAverage ? _self.ratingAverage : ratingAverage // ignore: cast_nullable_to_non_nullable
as double,ratingCount: null == ratingCount ? _self.ratingCount : ratingCount // ignore: cast_nullable_to_non_nullable
as int,overview: null == overview ? _self.overview : overview // ignore: cast_nullable_to_non_nullable
as String,itinerary: null == itinerary ? _self.itinerary : itinerary // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>,inclusions: null == inclusions ? _self.inclusions : inclusions // ignore: cast_nullable_to_non_nullable
as List<String>,latitude: null == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double,longitude: null == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double,availableDates: null == availableDates ? _self.availableDates : availableDates // ignore: cast_nullable_to_non_nullable
as List<DateTime>,privateVehicleSurcharge: null == privateVehicleSurcharge ? _self.privateVehicleSurcharge : privateVehicleSurcharge // ignore: cast_nullable_to_non_nullable
as double,groupSizeOptions: null == groupSizeOptions ? _self.groupSizeOptions : groupSizeOptions // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>,
  ));
}

}


/// Adds pattern-matching-related methods to [Tour].
extension TourPatterns on Tour {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Tour value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Tour() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Tour value)  $default,){
final _that = this;
switch (_that) {
case _Tour():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Tour value)?  $default,){
final _that = this;
switch (_that) {
case _Tour() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String destination,  String category,  List<String> badges,  String heroImageUrl,  List<String> galleryImageUrls,  double pricePerPerson,  String currency,  int durationDays,  int maxParticipants,  double ratingAverage,  int ratingCount,  String overview,  List<Map<String, dynamic>> itinerary,  List<String> inclusions,  double latitude,  double longitude,  List<DateTime> availableDates,  double privateVehicleSurcharge,  List<Map<String, dynamic>> groupSizeOptions)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Tour() when $default != null:
return $default(_that.id,_that.title,_that.destination,_that.category,_that.badges,_that.heroImageUrl,_that.galleryImageUrls,_that.pricePerPerson,_that.currency,_that.durationDays,_that.maxParticipants,_that.ratingAverage,_that.ratingCount,_that.overview,_that.itinerary,_that.inclusions,_that.latitude,_that.longitude,_that.availableDates,_that.privateVehicleSurcharge,_that.groupSizeOptions);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String destination,  String category,  List<String> badges,  String heroImageUrl,  List<String> galleryImageUrls,  double pricePerPerson,  String currency,  int durationDays,  int maxParticipants,  double ratingAverage,  int ratingCount,  String overview,  List<Map<String, dynamic>> itinerary,  List<String> inclusions,  double latitude,  double longitude,  List<DateTime> availableDates,  double privateVehicleSurcharge,  List<Map<String, dynamic>> groupSizeOptions)  $default,) {final _that = this;
switch (_that) {
case _Tour():
return $default(_that.id,_that.title,_that.destination,_that.category,_that.badges,_that.heroImageUrl,_that.galleryImageUrls,_that.pricePerPerson,_that.currency,_that.durationDays,_that.maxParticipants,_that.ratingAverage,_that.ratingCount,_that.overview,_that.itinerary,_that.inclusions,_that.latitude,_that.longitude,_that.availableDates,_that.privateVehicleSurcharge,_that.groupSizeOptions);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String destination,  String category,  List<String> badges,  String heroImageUrl,  List<String> galleryImageUrls,  double pricePerPerson,  String currency,  int durationDays,  int maxParticipants,  double ratingAverage,  int ratingCount,  String overview,  List<Map<String, dynamic>> itinerary,  List<String> inclusions,  double latitude,  double longitude,  List<DateTime> availableDates,  double privateVehicleSurcharge,  List<Map<String, dynamic>> groupSizeOptions)?  $default,) {final _that = this;
switch (_that) {
case _Tour() when $default != null:
return $default(_that.id,_that.title,_that.destination,_that.category,_that.badges,_that.heroImageUrl,_that.galleryImageUrls,_that.pricePerPerson,_that.currency,_that.durationDays,_that.maxParticipants,_that.ratingAverage,_that.ratingCount,_that.overview,_that.itinerary,_that.inclusions,_that.latitude,_that.longitude,_that.availableDates,_that.privateVehicleSurcharge,_that.groupSizeOptions);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Tour implements Tour {
  const _Tour({required this.id, required this.title, required this.destination, required this.category, required final  List<String> badges, required this.heroImageUrl, required final  List<String> galleryImageUrls, required this.pricePerPerson, required this.currency, required this.durationDays, required this.maxParticipants, required this.ratingAverage, required this.ratingCount, required this.overview, required final  List<Map<String, dynamic>> itinerary, required final  List<String> inclusions, required this.latitude, required this.longitude, required final  List<DateTime> availableDates, required this.privateVehicleSurcharge, required final  List<Map<String, dynamic>> groupSizeOptions}): _badges = badges,_galleryImageUrls = galleryImageUrls,_itinerary = itinerary,_inclusions = inclusions,_availableDates = availableDates,_groupSizeOptions = groupSizeOptions;
  factory _Tour.fromJson(Map<String, dynamic> json) => _$TourFromJson(json);

@override final  String id;
@override final  String title;
@override final  String destination;
@override final  String category;
 final  List<String> _badges;
@override List<String> get badges {
  if (_badges is EqualUnmodifiableListView) return _badges;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_badges);
}

@override final  String heroImageUrl;
 final  List<String> _galleryImageUrls;
@override List<String> get galleryImageUrls {
  if (_galleryImageUrls is EqualUnmodifiableListView) return _galleryImageUrls;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_galleryImageUrls);
}

@override final  double pricePerPerson;
@override final  String currency;
@override final  int durationDays;
@override final  int maxParticipants;
@override final  double ratingAverage;
@override final  int ratingCount;
@override final  String overview;
 final  List<Map<String, dynamic>> _itinerary;
@override List<Map<String, dynamic>> get itinerary {
  if (_itinerary is EqualUnmodifiableListView) return _itinerary;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_itinerary);
}

 final  List<String> _inclusions;
@override List<String> get inclusions {
  if (_inclusions is EqualUnmodifiableListView) return _inclusions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_inclusions);
}

@override final  double latitude;
@override final  double longitude;
 final  List<DateTime> _availableDates;
@override List<DateTime> get availableDates {
  if (_availableDates is EqualUnmodifiableListView) return _availableDates;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_availableDates);
}

@override final  double privateVehicleSurcharge;
 final  List<Map<String, dynamic>> _groupSizeOptions;
@override List<Map<String, dynamic>> get groupSizeOptions {
  if (_groupSizeOptions is EqualUnmodifiableListView) return _groupSizeOptions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_groupSizeOptions);
}


/// Create a copy of Tour
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TourCopyWith<_Tour> get copyWith => __$TourCopyWithImpl<_Tour>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TourToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Tour&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.destination, destination) || other.destination == destination)&&(identical(other.category, category) || other.category == category)&&const DeepCollectionEquality().equals(other._badges, _badges)&&(identical(other.heroImageUrl, heroImageUrl) || other.heroImageUrl == heroImageUrl)&&const DeepCollectionEquality().equals(other._galleryImageUrls, _galleryImageUrls)&&(identical(other.pricePerPerson, pricePerPerson) || other.pricePerPerson == pricePerPerson)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.durationDays, durationDays) || other.durationDays == durationDays)&&(identical(other.maxParticipants, maxParticipants) || other.maxParticipants == maxParticipants)&&(identical(other.ratingAverage, ratingAverage) || other.ratingAverage == ratingAverage)&&(identical(other.ratingCount, ratingCount) || other.ratingCount == ratingCount)&&(identical(other.overview, overview) || other.overview == overview)&&const DeepCollectionEquality().equals(other._itinerary, _itinerary)&&const DeepCollectionEquality().equals(other._inclusions, _inclusions)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&const DeepCollectionEquality().equals(other._availableDates, _availableDates)&&(identical(other.privateVehicleSurcharge, privateVehicleSurcharge) || other.privateVehicleSurcharge == privateVehicleSurcharge)&&const DeepCollectionEquality().equals(other._groupSizeOptions, _groupSizeOptions));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,title,destination,category,const DeepCollectionEquality().hash(_badges),heroImageUrl,const DeepCollectionEquality().hash(_galleryImageUrls),pricePerPerson,currency,durationDays,maxParticipants,ratingAverage,ratingCount,overview,const DeepCollectionEquality().hash(_itinerary),const DeepCollectionEquality().hash(_inclusions),latitude,longitude,const DeepCollectionEquality().hash(_availableDates),privateVehicleSurcharge,const DeepCollectionEquality().hash(_groupSizeOptions)]);

@override
String toString() {
  return 'Tour(id: $id, title: $title, destination: $destination, category: $category, badges: $badges, heroImageUrl: $heroImageUrl, galleryImageUrls: $galleryImageUrls, pricePerPerson: $pricePerPerson, currency: $currency, durationDays: $durationDays, maxParticipants: $maxParticipants, ratingAverage: $ratingAverage, ratingCount: $ratingCount, overview: $overview, itinerary: $itinerary, inclusions: $inclusions, latitude: $latitude, longitude: $longitude, availableDates: $availableDates, privateVehicleSurcharge: $privateVehicleSurcharge, groupSizeOptions: $groupSizeOptions)';
}


}

/// @nodoc
abstract mixin class _$TourCopyWith<$Res> implements $TourCopyWith<$Res> {
  factory _$TourCopyWith(_Tour value, $Res Function(_Tour) _then) = __$TourCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String destination, String category, List<String> badges, String heroImageUrl, List<String> galleryImageUrls, double pricePerPerson, String currency, int durationDays, int maxParticipants, double ratingAverage, int ratingCount, String overview, List<Map<String, dynamic>> itinerary, List<String> inclusions, double latitude, double longitude, List<DateTime> availableDates, double privateVehicleSurcharge, List<Map<String, dynamic>> groupSizeOptions
});




}
/// @nodoc
class __$TourCopyWithImpl<$Res>
    implements _$TourCopyWith<$Res> {
  __$TourCopyWithImpl(this._self, this._then);

  final _Tour _self;
  final $Res Function(_Tour) _then;

/// Create a copy of Tour
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? destination = null,Object? category = null,Object? badges = null,Object? heroImageUrl = null,Object? galleryImageUrls = null,Object? pricePerPerson = null,Object? currency = null,Object? durationDays = null,Object? maxParticipants = null,Object? ratingAverage = null,Object? ratingCount = null,Object? overview = null,Object? itinerary = null,Object? inclusions = null,Object? latitude = null,Object? longitude = null,Object? availableDates = null,Object? privateVehicleSurcharge = null,Object? groupSizeOptions = null,}) {
  return _then(_Tour(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,destination: null == destination ? _self.destination : destination // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,badges: null == badges ? _self._badges : badges // ignore: cast_nullable_to_non_nullable
as List<String>,heroImageUrl: null == heroImageUrl ? _self.heroImageUrl : heroImageUrl // ignore: cast_nullable_to_non_nullable
as String,galleryImageUrls: null == galleryImageUrls ? _self._galleryImageUrls : galleryImageUrls // ignore: cast_nullable_to_non_nullable
as List<String>,pricePerPerson: null == pricePerPerson ? _self.pricePerPerson : pricePerPerson // ignore: cast_nullable_to_non_nullable
as double,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,durationDays: null == durationDays ? _self.durationDays : durationDays // ignore: cast_nullable_to_non_nullable
as int,maxParticipants: null == maxParticipants ? _self.maxParticipants : maxParticipants // ignore: cast_nullable_to_non_nullable
as int,ratingAverage: null == ratingAverage ? _self.ratingAverage : ratingAverage // ignore: cast_nullable_to_non_nullable
as double,ratingCount: null == ratingCount ? _self.ratingCount : ratingCount // ignore: cast_nullable_to_non_nullable
as int,overview: null == overview ? _self.overview : overview // ignore: cast_nullable_to_non_nullable
as String,itinerary: null == itinerary ? _self._itinerary : itinerary // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>,inclusions: null == inclusions ? _self._inclusions : inclusions // ignore: cast_nullable_to_non_nullable
as List<String>,latitude: null == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double,longitude: null == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double,availableDates: null == availableDates ? _self._availableDates : availableDates // ignore: cast_nullable_to_non_nullable
as List<DateTime>,privateVehicleSurcharge: null == privateVehicleSurcharge ? _self.privateVehicleSurcharge : privateVehicleSurcharge // ignore: cast_nullable_to_non_nullable
as double,groupSizeOptions: null == groupSizeOptions ? _self._groupSizeOptions : groupSizeOptions // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>,
  ));
}


}

// dart format on
