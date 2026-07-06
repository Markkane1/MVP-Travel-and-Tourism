import 'package:freezed_annotation/freezed_annotation.dart';

part 'tour.freezed.dart';
part 'tour.g.dart';

@freezed
abstract class Tour with _$Tour {
  const Tour._();

  const factory Tour({
    @JsonKey(includeToJson: false) @Default('') String id, // Provided by Firestore doc ID, not written back
    required String title,
    required String destination,
    required String category,
    @Default([]) List<String> badges,
    @Default('') String heroImageUrl,
    @Default([]) List<String> galleryImageUrls,
    required double pricePerPerson,
    @Default('USD') String currency,
    required int durationDays,
    @Default(10) int maxParticipants,
    @Default(0.0) double ratingAverage,
    @Default(0) int ratingCount,
    @Default('') String overview,
    @Default([]) List<Map<String, dynamic>> itinerary,
    @Default([]) List<String> inclusions,
    @Default(0.0) double latitude,
    @Default(0.0) double longitude,
    @Default([]) List<DateTime> availableDates,
    @Default(0.0) double privateVehicleSurcharge,
    @Default([]) List<Map<String, dynamic>> groupSizeOptions,
  }) = _Tour;

  factory Tour.fromJson(Map<String, dynamic> json) => _$TourFromJson(json);

  factory Tour.fromFirestore(Map<String, dynamic> data, String documentId) {
    return Tour.fromJson({
      ...data,
      'id': documentId,
    });
  }
}
