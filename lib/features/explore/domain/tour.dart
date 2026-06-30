import 'package:freezed_annotation/freezed_annotation.dart';

part 'tour.freezed.dart';
part 'tour.g.dart';

/// Represents a travel tour package data model.
@freezed
abstract class Tour with _$Tour {
  const factory Tour({
    required String id,
    required String title,
    required String destination,
    required String category,
    required List<String> badges,
    required String heroImageUrl,
    required List<String> galleryImageUrls,
    required double pricePerPerson,
    required String currency,
    required int durationDays,
    required int maxParticipants,
    required double rating,
    required String overview,
    required List<Map<String, dynamic>> itinerary,
    required List<String> inclusions,
  }) = _Tour;

  factory Tour.fromJson(Map<String, dynamic> json) => _$TourFromJson(json);
}
