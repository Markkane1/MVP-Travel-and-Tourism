import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final totalBookingsProvider = StreamProvider.autoDispose<int>((ref) {
  return FirebaseFirestore.instance
      .collection('bookings')
      .snapshots()
      .map((snap) => snap.size);
});

final totalToursProvider = StreamProvider.autoDispose<int>((ref) {
  return FirebaseFirestore.instance
      .collection('tours')
      .where('isActive', isEqualTo: true)
      .snapshots()
      .map((snap) => snap.size);
});

final totalConciergeThreadsProvider = StreamProvider.autoDispose<int>((ref) {
  return FirebaseFirestore.instance
      .collection('concierge_threads')
      .snapshots()
      .map((snap) => snap.size);
});

final totalReviewsProvider = StreamProvider.autoDispose<int>((ref) {
  return FirebaseFirestore.instance
      .collectionGroup('reviews')
      .snapshots()
      .map((snap) => snap.size);
});

// Phase 9 additional reporting metrics:

final pendingBookingsProvider = StreamProvider.autoDispose<int>((ref) {
  return FirebaseFirestore.instance
      .collection('bookings')
      .where('status', isEqualTo: 'pending')
      .snapshots()
      .map((snap) => snap.size);
});

final confirmedBookingsProvider = StreamProvider.autoDispose<int>((ref) {
  return FirebaseFirestore.instance
      .collection('bookings')
      .where('status', isEqualTo: 'confirmed')
      .snapshots()
      .map((snap) => snap.size);
});

final activeServicesProvider = StreamProvider.autoDispose<int>((ref) {
  return FirebaseFirestore.instance
      .collection('services')
      .where('isActive', isEqualTo: true)
      .snapshots()
      .map((snap) => snap.size);
});

final recentRefundsProvider = StreamProvider.autoDispose<int>((ref) {
  // We can count refunds by querying the admin audit logs for the refund action
  return FirebaseFirestore.instance
      .collection('admin_audit_logs')
      .where('action', isEqualTo: 'adminIssueRefund')
      .snapshots()
      .map((snap) => snap.size);
});
