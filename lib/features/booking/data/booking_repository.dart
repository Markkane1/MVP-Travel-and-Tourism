import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/services/api_client.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/errors/app_exception.dart';
import '../domain/booking.dart';

part 'booking_repository.g.dart';

/// Repository responsible for handling API Booking database records.
class BookingRepository {
  final ApiClient _api;

  BookingRepository(this._api);

  /// Generates a new unique booking ID.
  String generateNewBookingId() {
    return DateTime.now().microsecondsSinceEpoch.toString();
  }

  Future<Result<String>> createPendingBooking(Booking booking) async {
    try {
      // ponytail: API schema lacks tourDate/pickup/party fields; add columns before persisting those.
      final created = await _api.postJson('/bookings', {
        'tourId': booking.tourId,
        'totalAmount': booking.totalPrice.round(),
        'currency': booking.currency,
      });
      return Result.success(created['id'] as String);
    } catch (e) {
      return Result.failure(
        AppException.unknown('Booking creation failed: ${e.toString()}'),
      );
    }
  }

  /// Streams a single booking by its ID from the API.
  Stream<Booking?> watchBooking(String bookingId) {
    return Stream.fromFuture(_fetchBooking(bookingId));
  }

  /// Streams all bookings for a specific user from the API.
  Stream<List<Booking>> watchUserBookings(String userId) {
    return Stream.fromFuture(_fetchUserBookings());
  }

  Future<Booking?> _fetchBooking(String bookingId) async {
    final data = await _api.getJson(
      '/bookings/${Uri.encodeComponent(bookingId)}',
      authenticated: true,
    );
    if (data == null) return null;
    return Booking.fromJson(
      _mapBookingData(Map<String, dynamic>.from(data as Map)),
    );
  }

  Future<List<Booking>> _fetchUserBookings() async {
    final data = await _api.getJson('/users/me/bookings', authenticated: true);
    final bookings = (data as List)
        .whereType<Map>()
        .map(
          (booking) => Booking.fromJson(
            _mapBookingData(Map<String, dynamic>.from(booking)),
          ),
        )
        .toList();
    bookings.sort((a, b) => a.tourDate.compareTo(b.tourDate));
    return bookings;
  }
}

Map<String, dynamic> _mapBookingData(Map<String, dynamic> data) {
  final tourSnapshot = data['tourSnapshot'] is Map
      ? Map<String, dynamic>.from(data['tourSnapshot'] as Map)
      : <String, dynamic>{};

  data['userId'] = data['userId'] as String? ?? '';
  data['tourId'] = data['tourId'] as String? ?? '';
  tourSnapshot['title'] = (tourSnapshot['title'] as String?) ?? '';
  tourSnapshot['heroImageUrl'] =
      (tourSnapshot['heroImageUrl'] as String?) ?? '';
  tourSnapshot['destination'] = (tourSnapshot['destination'] as String?) ?? '';
  data['tourSnapshot'] = tourSnapshot;
  data['tourDate'] =
      data['tourDate'] ?? data['createdAt'] ?? DateTime.now().toIso8601String();
  data['adults'] = (data['adults'] as num?)?.toInt() ?? 0;
  data['children'] = (data['children'] as num?)?.toInt() ?? 0;
  data['privateVehicle'] = data['privateVehicle'] as bool? ?? false;
  data['groupSizeOption'] = data['groupSizeOption'] as String? ?? '';
  data['pickupLocation'] = data['pickupLocation'] as String? ?? '';
  data['specialRequests'] = data['specialRequests'] as String? ?? '';
  data['totalPrice'] =
      (data['totalPrice'] as num?)?.toDouble() ??
      (data['totalAmount'] as num?)?.toDouble() ??
      0.0;
  data['currency'] = data['currency'] as String? ?? 'USD';
  data['status'] = (data['status'] as String? ?? 'pending').toLowerCase();
  data['stripePaymentIntentId'] = data['stripePaymentIntentId'] as String?;
  data['bookingReferenceCode'] = data['bookingReferenceCode'] as String?;
  data['reviewed'] = data['reviewed'] as bool? ?? false;
  data['createdAt'] = data['createdAt'] ?? DateTime.now().toIso8601String();
  return data;
}

@riverpod
BookingRepository bookingRepository(Ref ref) {
  return BookingRepository(ref.watch(apiClientProvider));
}

@riverpod
Stream<Booking?> bookingDetails(Ref ref, String bookingId) {
  return ref.watch(bookingRepositoryProvider).watchBooking(bookingId);
}

@riverpod
Stream<List<Booking>> userBookings(Ref ref, String userId) {
  return ref.watch(bookingRepositoryProvider).watchUserBookings(userId);
}
