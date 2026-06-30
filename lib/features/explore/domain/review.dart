import 'package:freezed_annotation/freezed_annotation.dart';

part 'review.freezed.dart';
part 'review.g.dart';

/// Represents a traveler review testimonial.
@freezed
abstract class Review with _$Review {
  const factory Review({
    required String id,
    required String userName,
    required String userPhotoUrl,
    required double rating,
    required String comment,
    required DateTime createdAt,
  }) = _Review;

  factory Review.fromJson(Map<String, dynamic> json) => _$ReviewFromJson(json);
}
