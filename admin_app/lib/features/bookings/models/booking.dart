import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'booking.freezed.dart';
part 'booking.g.dart';

@freezed
abstract class Booking with _$Booking {
  const Booking._();

  const factory Booking({
    @JsonKey(includeToJson: false) @Default('') String id,
    required String userId,
    required String tourId,
    required String status,
    required double totalPrice,
    @Default('USD') String currency,
    String? bookingReferenceCode,
    @Default(false) bool refunded,
    String? refundReason,
    String? adminNotes,
    String? lastAdminActionBy,
    Map<String, dynamic>? tourSnapshot,
    Map<String, dynamic>? participantCounts,
    Map<String, dynamic>? paymentReferences,
    @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson) DateTime? bookingDate,
    @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson) DateTime? refundedAt,
    @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson) DateTime? lastAdminActionAt,
    @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson) DateTime? createdAt,
  }) = _Booking;

  factory Booking.fromJson(Map<String, dynamic> json) => _$BookingFromJson(json);

  factory Booking.fromFirestore(Map<String, dynamic> data, String documentId) {
    return Booking.fromJson({
      ...data,
      'id': documentId,
    });
  }
}

DateTime? _timestampFromJson(dynamic value) {
  if (value is Timestamp) {
    return value.toDate();
  }
  return null;
}

dynamic _timestampToJson(DateTime? value) {
  if (value == null) return null;
  return Timestamp.fromDate(value);
}
