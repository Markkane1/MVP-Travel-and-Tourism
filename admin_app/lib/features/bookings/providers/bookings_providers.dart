import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/booking.dart';

final bookingsStreamProvider = StreamProvider.autoDispose<List<Booking>>((ref) {
  return FirebaseFirestore.instance
      .collection('bookings')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) => Booking.fromFirestore(doc.data(), doc.id)).toList();
  });
});

class BookingsApi {
  Future<void> updateBookingStatus(String bookingId, String nextStatus, {String? reason}) async {
    final callable = FirebaseFunctions.instance.httpsCallable('adminUpdateBookingStatus');
    await callable.call({
      'bookingId': bookingId,
      'nextStatus': nextStatus,
      if (reason != null) 'reason': reason,
    });
  }

  Future<void> issueRefund(String bookingId, String reason) async {
    final callable = FirebaseFunctions.instance.httpsCallable('adminIssueRefund');
    await callable.call({
      'bookingId': bookingId,
      'reason': reason,
    });
  }
}

final bookingsApiProvider = Provider<BookingsApi>((ref) {
  return BookingsApi();
});
