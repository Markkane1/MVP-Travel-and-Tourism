import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final totalBookingsProvider = FutureProvider.autoDispose<int>((ref) async {
  final countQuery = await FirebaseFirestore.instance.collection('bookings').count().get();
  return countQuery.count ?? 0;
});

final totalToursProvider = FutureProvider.autoDispose<int>((ref) async {
  final countQuery = await FirebaseFirestore.instance.collection('tours').count().get();
  return countQuery.count ?? 0;
});

final totalConciergeThreadsProvider = FutureProvider.autoDispose<int>((ref) async {
  final countQuery = await FirebaseFirestore.instance.collection('concierge_threads').count().get();
  return countQuery.count ?? 0;
});

final totalReviewsProvider = FutureProvider.autoDispose<int>((ref) async {
  // Uses collectionGroup to count reviews across all tours
  final countQuery = await FirebaseFirestore.instance.collectionGroup('reviews').count().get();
  return countQuery.count ?? 0;
});
