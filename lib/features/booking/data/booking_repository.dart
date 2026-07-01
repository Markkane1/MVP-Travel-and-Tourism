import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../domain/booking.dart';

part 'booking_repository.g.dart';

/// Repository responsible for handling Firestore Booking database records.
class BookingRepository {
  final FirebaseFirestore _firestore;

  BookingRepository(this._firestore);

  /// Creates a new booking document in `pending` status.
  /// 
  /// Per Firestore security rules, client-side writes:
  /// 1. Must have status == 'pending'
  /// 2. Must not contain 'stripePaymentIntentId' or 'bookingReferenceCode'
  /// 3. userId must match the authenticated user's UID.
  Future<void> createPendingBooking(Booking booking) async {
    final Map<String, dynamic> data = booking.toJson();

    // Security rules filter: these fields cannot be passed on document creation
    data.remove('stripePaymentIntentId');
    data.remove('bookingReferenceCode');

    // Convert DateTime objects to Firestore Timestamps for native Firestore querying
    data['tourDate'] = Timestamp.fromDate(booking.tourDate.toUtc());
    data['createdAt'] = Timestamp.fromDate(booking.createdAt.toUtc());

    await _firestore.collection('bookings').doc(booking.id).set(data);
  }
}

@riverpod
BookingRepository bookingRepository(Ref ref) {
  return BookingRepository(FirebaseFirestore.instance);
}
