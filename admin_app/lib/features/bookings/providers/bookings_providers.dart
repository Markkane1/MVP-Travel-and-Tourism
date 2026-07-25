import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/api_client.dart';
import '../models/booking.dart';

final bookingsStreamProvider = StreamProvider.autoDispose<List<Booking>>((ref) {
  final api = ref.watch(apiClientProvider);
  return Stream.fromFuture(
    api.getJson('/admin/bookings').then((data) {
      return (data as List)
          .map((json) => Booking.fromJson(_bookingJson(json)))
          .toList();
    }),
  );
});

Map<String, dynamic> _bookingJson(dynamic value) {
  final json = Map<String, dynamic>.from(value as Map);
  final amount = json['totalAmount'] ?? json['totalPrice'] ?? 0;
  final totalPrice = amount is num
      ? amount.toDouble()
      : double.tryParse(amount?.toString() ?? '') ?? 0.0;
  return {
    ...json,
    'id': json['id']?.toString() ?? '',
    'userId': json['userId']?.toString() ?? '',
    'tourId': json['tourId'] ?? '',
    'status': (json['status'] ?? '').toString().toLowerCase(),
    'totalPrice': totalPrice,
    'currency': json['currency']?.toString() ?? 'USD',
    'bookingDate': json['bookingDate'] ?? json['createdAt'],
  };
}

class BookingsApi {
  final ApiClient _api;

  BookingsApi(this._api);

  Future<void> updateBookingStatus(
    String bookingId,
    String nextStatus, {
    String? reason,
  }) async {
    await _api.postJson(
      '/admin/bookings/${Uri.encodeComponent(bookingId)}/status',
      {'status': nextStatus.toUpperCase(), 'notes': reason},
    );
  }

  Future<void> requestRefund(String bookingId, String reason) async {
    await _api.postJson(
      '/admin/bookings/${Uri.encodeComponent(bookingId)}/refund',
      {'reason': reason},
    );
  }
}

final bookingsApiProvider = Provider<BookingsApi>(
  (ref) => BookingsApi(ref.watch(apiClientProvider)),
);
