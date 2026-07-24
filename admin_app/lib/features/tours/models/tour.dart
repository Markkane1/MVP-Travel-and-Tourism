import 'package:freezed_annotation/freezed_annotation.dart';

part 'tour.freezed.dart';
part 'tour.g.dart';

@freezed
abstract class Tour with _$Tour {
  const Tour._();

  const factory Tour({
    @JsonKey(includeToJson: false)
    @Default('')
    String id,
    @Default('') String title,
    @Default('') String destination,
    @Default('') String category,
    @Default([]) List<String> badges,
    @Default('') String heroImageUrl,
    @Default([]) List<String> galleryImageUrls,
    @Default(0.0) double pricePerPerson,
    @Default('USD') String currency,
    @Default(0) int durationDays,
    @Default(10) int maxParticipants,
    @Default(0.0) double ratingAverage,
    @Default(0) int ratingCount,
    @Default('') String overview,
    @Default([]) List<Map<String, dynamic>> itinerary,
    @Default([]) List<String> inclusions,
    @Default(0.0) double latitude,
    @Default(0.0) double longitude,
    @JsonKey(fromJson: _timestampListFromJson, toJson: _timestampListToJson)
    @Default([])
    List<DateTime> availableDates,
    @Default(0.0) double privateVehicleSurcharge,
    @Default([]) List<Map<String, dynamic>> groupSizeOptions,
    @Default(true) bool isActive,
  }) = _Tour;

  factory Tour.fromJson(Map<String, dynamic> json) => _$TourFromJson(json);

}

List<DateTime> _timestampListFromJson(dynamic value) {
  if (value is List) {
    return value.map((e) {
      if (e is String) return DateTime.tryParse(e) ?? DateTime.now();
      if (e is Map && e['startDate'] is String) {
        return DateTime.tryParse(e['startDate'] as String) ?? DateTime.now();
      }
      return DateTime.now();
    }).toList();
  }
  return [];
}

dynamic _timestampListToJson(List<DateTime> value) {
  return value.map((e) => e.toIso8601String()).toList();
}
