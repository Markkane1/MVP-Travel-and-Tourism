import 'package:freezed_annotation/freezed_annotation.dart';

part 'booking.freezed.dart';
part 'booking.g.dart';

/// Denormalized tour summary snapshot stored inside the Booking document.
@freezed
abstract class TourSnapshot with _$TourSnapshot {
  const factory TourSnapshot({
    required String title,
    required String heroImageUrl,
    required String destination,
  }) = _TourSnapshot;

  factory TourSnapshot.fromJson(Map<String, dynamic> json) =>
      _$TourSnapshotFromJson(json);
}

/// Represents a customer booking record.
@freezed
abstract class Booking with _$Booking {
  const factory Booking({
    required String id,
    required String userId,
    required String tourId,
    required TourSnapshot tourSnapshot,
    required DateTime tourDate,
    required int adults,
    required int children,
    required bool privateVehicle,
    required String groupSizeOption,
    required String pickupLocation,
    String? specialRequests,
    required double totalPrice,
    required String currency,
    required String status, // 'pending' | 'confirmed' | 'cancelled' | 'completed'
    String? stripePaymentIntentId,
    String? bookingReferenceCode, // Managed by Cloud Functions
    required DateTime createdAt,
  }) = _Booking;

  factory Booking.fromJson(Map<String, dynamic> json) =>
      _$BookingFromJson(json);
}
