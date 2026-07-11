import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/utils/safe_stream.dart';
import '../../../../core/errors/app_exception.dart';
import '../domain/booking.dart';

part 'booking_repository.g.dart';

/// Repository responsible for handling Firestore Booking database records.
class BookingRepository {
  final FirebaseFirestore _firestore;

  BookingRepository(this._firestore);

  /// Generates a new unique booking ID.
  String generateNewBookingId() {
    return _firestore.collection('bookings').doc().id;
  }

  /// Creates a new booking document in `pending` status.
  ///
  /// Per Firestore security rules, client-side writes:
  /// 1. Must have status == 'pending'
  /// 2. Must not contain 'stripePaymentIntentId' or 'bookingReferenceCode'
  /// 3. userId must match the authenticated user's UID.
  Future<Result<void>> createPendingBooking(Booking booking) async {
    try {
      final Map<String, dynamic> data = booking.toJson();

      // Security rules filter: these fields cannot be passed on document creation
      data.remove('stripePaymentIntentId');
      data.remove('bookingReferenceCode');
      data.remove('reviewed');

      // Convert DateTime objects to Firestore Timestamps for native Firestore querying
      data['tourDate'] = Timestamp.fromDate(booking.tourDate.toUtc());
      data['createdAt'] = Timestamp.fromDate(booking.createdAt.toUtc());
      data['tourSnapshot'] = booking.tourSnapshot.toJson();

      await _firestore.collection('bookings').doc(booking.id).set(data);
      return const Result.success(null);
    } catch (e) {
      return Result.failure(
        AppException.unknown('Booking creation failed: ${e.toString()}'),
      );
    }
  }

  /// Streams a single booking by its ID from Firestore.
  Stream<Booking?> watchBooking(String bookingId) {
    return _firestore
        .collection('bookings')
        .doc(bookingId)
        .snapshots()
        .map((doc) {
          if (!doc.exists) return null;
          final data = Map<String, dynamic>.from(doc.data() as Map? ?? {});
          data['id'] = doc.id;

          if (data['tourDate'] is Timestamp) {
            data['tourDate'] = (data['tourDate'] as Timestamp)
                .toDate()
                .toIso8601String();
          }
          if (data['createdAt'] is Timestamp) {
            data['createdAt'] = (data['createdAt'] as Timestamp)
                .toDate()
                .toIso8601String();
          }

          return Booking.fromJson(_mapBookingData(data));
        })
        .mapAppException('Failed to load booking');
  }

  /// Streams all bookings for a specific user from Firestore.
  Stream<List<Booking>> watchUserBookings(String userId) {
    return _firestore
        .collection('bookings')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          final bookings = snapshot.docs.map((doc) {
            final data = Map<String, dynamic>.from(doc.data() as Map? ?? {});
            data['id'] = doc.id;

            if (data['tourDate'] is Timestamp) {
              data['tourDate'] = (data['tourDate'] as Timestamp)
                  .toDate()
                  .toIso8601String();
            }
            if (data['createdAt'] is Timestamp) {
              data['createdAt'] = (data['createdAt'] as Timestamp)
                  .toDate()
                  .toIso8601String();
            }

            return Booking.fromJson(_mapBookingData(data));
          }).toList();

          bookings.sort((a, b) => a.tourDate.compareTo(b.tourDate));
          return bookings;
        })
        .mapAppException('Failed to load bookings');
  }
}

Map<String, dynamic> _mapBookingData(Map<String, dynamic> data) {
  final tourSnapshot = data['tourSnapshot'] is Map
      ? Map<String, dynamic>.from(data['tourSnapshot'] as Map)
      : <String, dynamic>{};

  data['userId'] = data['userId'] as String? ?? '';
  data['tourId'] = data['tourId'] as String? ?? '';
  tourSnapshot['title'] = (tourSnapshot['title'] as String?) ?? '';
  tourSnapshot['heroImageUrl'] = (tourSnapshot['heroImageUrl'] as String?) ?? '';
  tourSnapshot['destination'] = (tourSnapshot['destination'] as String?) ?? '';
  data['tourSnapshot'] = tourSnapshot;
  data['tourDate'] = data['tourDate'] ?? DateTime.now().toIso8601String();
  data['adults'] = (data['adults'] as num?)?.toInt() ?? 0;
  data['children'] = (data['children'] as num?)?.toInt() ?? 0;
  data['privateVehicle'] = data['privateVehicle'] as bool? ?? false;
  data['groupSizeOption'] = data['groupSizeOption'] as String? ?? '';
  data['pickupLocation'] = data['pickupLocation'] as String? ?? '';
  data['specialRequests'] = data['specialRequests'] as String? ?? '';
  data['totalPrice'] = (data['totalPrice'] as num?)?.toDouble() ?? 0.0;
  data['currency'] = data['currency'] as String? ?? 'USD';
  data['status'] = data['status'] as String? ?? 'pending';
  data['stripePaymentIntentId'] = data['stripePaymentIntentId'] as String?;
  data['bookingReferenceCode'] = data['bookingReferenceCode'] as String?;
  data['reviewed'] = data['reviewed'] as bool? ?? false;
  data['createdAt'] = data['createdAt'] ?? DateTime.now().toIso8601String();
  return data;
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
