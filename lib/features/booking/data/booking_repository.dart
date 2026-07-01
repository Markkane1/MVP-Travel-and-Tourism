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

  /// Streams a single booking by its ID from Firestore.
  Stream<Booking?> watchBooking(String bookingId) {
    return _firestore.collection('bookings').doc(bookingId).snapshots().map((doc) {
      if (!doc.exists) return null;
      final data = doc.data()!;
      data['id'] = doc.id;

      if (data['tourDate'] is Timestamp) {
        data['tourDate'] = (data['tourDate'] as Timestamp).toDate().toIso8601String();
      }
      if (data['createdAt'] is Timestamp) {
        data['createdAt'] = (data['createdAt'] as Timestamp).toDate().toIso8601String();
      }

      return Booking.fromJson(data);
    });
  }

  /// Streams all bookings for a specific user from Firestore.
  Stream<List<Booking>> watchUserBookings(String userId) {
    return _firestore
        .collection('bookings')
        .where('userId', isEqualTo: userId)
        .orderBy('tourDate', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;

        if (data['tourDate'] is Timestamp) {
          data['tourDate'] = (data['tourDate'] as Timestamp).toDate().toIso8601String();
        }
        if (data['createdAt'] is Timestamp) {
          data['createdAt'] = (data['createdAt'] as Timestamp).toDate().toIso8601String();
        }

        return Booking.fromJson(data);
      }).toList();
    });
  }
}

@riverpod
BookingRepository bookingRepository(Ref ref) {
  return BookingRepository(FirebaseFirestore.instance);
}

@riverpod
Stream<Booking?> bookingDetails(Ref ref, String bookingId) {
  return ref.watch(bookingRepositoryProvider).watchBooking(bookingId);
}

@riverpod
Stream<List<Booking>> userBookings(Ref ref, String userId) {
  return ref.watch(bookingRepositoryProvider).watchUserBookings(userId);
}
