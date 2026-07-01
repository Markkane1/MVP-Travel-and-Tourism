// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tour.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Tour _$TourFromJson(Map<String, dynamic> json) => _Tour(
  id: json['id'] as String,
  title: json['title'] as String,
  destination: json['destination'] as String,
  category: json['category'] as String,
  badges: (json['badges'] as List<dynamic>).map((e) => e as String).toList(),
  heroImageUrl: json['heroImageUrl'] as String,
  galleryImageUrls: (json['galleryImageUrls'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  pricePerPerson: (json['pricePerPerson'] as num).toDouble(),
  currency: json['currency'] as String,
  durationDays: (json['durationDays'] as num).toInt(),
  maxParticipants: (json['maxParticipants'] as num).toInt(),
  ratingAverage: (json['ratingAverage'] as num).toDouble(),
  ratingCount: (json['ratingCount'] as num).toInt(),
  overview: json['overview'] as String,
  itinerary: (json['itinerary'] as List<dynamic>)
      .map((e) => e as Map<String, dynamic>)
      .toList(),
  inclusions: (json['inclusions'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  latitude: (json['latitude'] as num).toDouble(),
  longitude: (json['longitude'] as num).toDouble(),
  availableDates: (json['availableDates'] as List<dynamic>)
      .map((e) => DateTime.parse(e as String))
      .toList(),
  privateVehicleSurcharge: (json['privateVehicleSurcharge'] as num).toDouble(),
  groupSizeOptions: (json['groupSizeOptions'] as List<dynamic>)
      .map((e) => e as Map<String, dynamic>)
      .toList(),
);

Map<String, dynamic> _$TourToJson(_Tour instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'destination': instance.destination,
  'category': instance.category,
  'badges': instance.badges,
  'heroImageUrl': instance.heroImageUrl,
  'galleryImageUrls': instance.galleryImageUrls,
  'pricePerPerson': instance.pricePerPerson,
  'currency': instance.currency,
  'durationDays': instance.durationDays,
  'maxParticipants': instance.maxParticipants,
  'ratingAverage': instance.ratingAverage,
  'ratingCount': instance.ratingCount,
  'overview': instance.overview,
  'itinerary': instance.itinerary,
  'inclusions': instance.inclusions,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'availableDates': instance.availableDates
      .map((e) => e.toIso8601String())
      .toList(),
  'privateVehicleSurcharge': instance.privateVehicleSurcharge,
  'groupSizeOptions': instance.groupSizeOptions,
};
