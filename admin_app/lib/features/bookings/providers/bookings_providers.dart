import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/booking.dart';

final bookingsStreamProvider = StreamProvider.autoDispose<List<Booking>>((ref) {
  return FirebaseFirestore.instance
      .collection('bookings')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) {
        return snapshot.docs
            .map((doc) => Booking.fromFirestore(doc.data(), doc.id))
            .toList();
      });
});

class BookingsApi {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  // Allowed status transitions (mirrors the backend spec).
  static const _allowedTransitions = <String, List<String>>{
    'pending': ['confirmed', 'cancelled'],
    'confirmed': ['completed', 'cancelled'],
  };

  Future<void> updateBookingStatus(
    String bookingId,
    String nextStatus, {
    String? reason,
  }) async {
    final bookingDoc = await _db.collection('bookings').doc(bookingId).get();
    if (!bookingDoc.exists) throw Exception('Booking not found.');

    final currentStatus = bookingDoc.data()?['status'] as String? ?? '';
    final allowed = _allowedTransitions[currentStatus] ?? [];
    if (!allowed.contains(nextStatus)) {
      throw Exception('Invalid transition: $currentStatus → $nextStatus.');
    }

    final actor = _auth.currentUser;
    final batch = _db.batch();

    // 1. Update the booking.
    batch.update(_db.collection('bookings').doc(bookingId), {
      'status': nextStatus,
      'lastAdminActionAt': FieldValue.serverTimestamp(),
      'lastAdminActionBy': actor?.email ?? 'unknown',
      'adminNotes': ?reason,
    });

    // 2. Write audit log.
    batch.set(_db.collection('admin_audit_logs').doc(), {
      'actorUid': actor?.uid ?? 'unknown',
      'actorEmail': actor?.email ?? 'unknown',
      'action': 'adminUpdateBookingStatus',
      'targetType': 'booking',
      'targetId': bookingId,
      'summary': 'Status changed from $currentStatus to $nextStatus',
      'reason': ?reason,
      'before': {'status': currentStatus},
      'after': {'status': nextStatus},
      'createdAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }

  /// Marks a refund as requested on the booking. The actual Stripe refund
  /// must be processed manually in the Stripe Dashboard until a paid
  /// backend (Cloud Function) is available.
  Future<void> requestRefund(String bookingId, String reason) async {
    final actor = _auth.currentUser;
    final batch = _db.batch();

    batch.update(_db.collection('bookings').doc(bookingId), {
      'refundRequested': true,
      'refundReason': reason,
      'lastAdminActionAt': FieldValue.serverTimestamp(),
      'lastAdminActionBy': actor?.email ?? 'unknown',
    });

    batch.set(_db.collection('admin_audit_logs').doc(), {
      'actorUid': actor?.uid ?? 'unknown',
      'actorEmail': actor?.email ?? 'unknown',
      'action': 'adminRequestRefund',
      'targetType': 'booking',
      'targetId': bookingId,
      'summary': 'Refund requested. Manual Stripe action required.',
      'reason': reason,
      'createdAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }

  Future<void> addBooking(Booking newBooking) async {
    final actor = _auth.currentUser;
    final docRef = _db.collection('bookings').doc();
    final batch = _db.batch();

    final data = newBooking.toJson();
    data['id'] = docRef.id;
    data['createdAt'] = FieldValue.serverTimestamp();

    batch.set(docRef, data);

    batch.set(_db.collection('admin_audit_logs').doc(), {
      'actorUid': actor?.uid ?? 'unknown',
      'actorEmail': actor?.email ?? 'unknown',
      'action': 'adminCreateBooking',
      'targetType': 'booking',
      'targetId': docRef.id,
      'summary': 'Admin manually created booking for user ${newBooking.userId}',
      'createdAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }

  Future<void> updateBookingDetails(
    String bookingId,
    Map<String, dynamic> updates,
  ) async {
    final actor = _auth.currentUser;
    final batch = _db.batch();

    updates['lastAdminActionAt'] = FieldValue.serverTimestamp();
    updates['lastAdminActionBy'] = actor?.email ?? 'unknown';

    batch.update(_db.collection('bookings').doc(bookingId), updates);

    batch.set(_db.collection('admin_audit_logs').doc(), {
      'actorUid': actor?.uid ?? 'unknown',
      'actorEmail': actor?.email ?? 'unknown',
      'action': 'adminUpdateBookingDetails',
      'targetType': 'booking',
      'targetId': bookingId,
      'summary': 'Admin modified booking details (Dates, Participants, etc.)',
      'after': updates,
      'createdAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }
}

final bookingsApiProvider = Provider<BookingsApi>((ref) => BookingsApi());
