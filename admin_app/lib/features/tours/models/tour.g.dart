// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tour.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Tour _$TourFromJson(Map<String, dynamic> json) => _Tour(
  id: json['id'] as String? ?? '',
  title: json['title'] as String? ?? '',
  destination: json['destination'] as String? ?? '',
  category: json['category'] as String? ?? '',
  badges:
      (json['badges'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  heroImageUrl: json['heroImageUrl'] as String? ?? '',
  galleryImageUrls:
      (json['galleryImageUrls'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  pricePerPerson: (json['pricePerPerson'] as num?)?.toDouble() ?? 0.0,
  currency: json['currency'] as String? ?? 'USD',
  durationDays: (json['durationDays'] as num?)?.toInt() ?? 0,
  maxParticipants: (json['maxParticipants'] as num?)?.toInt() ?? 10,
  ratingAverage: (json['ratingAverage'] as num?)?.toDouble() ?? 0.0,
  ratingCount: (json['ratingCount'] as num?)?.toInt() ?? 0,
  overview: json['overview'] as String? ?? '',
  itinerary:
      (json['itinerary'] as List<dynamic>?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList() ??
      const [],
  inclusions:
      (json['inclusions'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
  longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
  availableDates: json['availableDates'] == null
      ? const []
      : _timestampListFromJson(json['availableDates']),
  privateVehicleSurcharge:
      (json['privateVehicleSurcharge'] as num?)?.toDouble() ?? 0.0,
  groupSizeOptions:
      (json['groupSizeOptions'] as List<dynamic>?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList() ??
      const [],
  isActive: json['isActive'] as bool? ?? true,
);

Map<String, dynamic> _$TourToJson(_Tour instance) => <String, dynamic>{
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
  'availableDates': _timestampListToJson(instance.availableDates),
  'privateVehicleSurcharge': instance.privateVehicleSurcharge,
  'groupSizeOptions': instance.groupSizeOptions,
  'isActive': instance.isActive,
};
