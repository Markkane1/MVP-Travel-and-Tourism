import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/tour.dart';

final toursStreamProvider = StreamProvider.autoDispose<List<Tour>>((ref) {
  return FirebaseFirestore.instance.collection('tours').snapshots().map((snapshot) {
    return snapshot.docs.map((doc) => Tour.fromFirestore(doc.data(), doc.id)).toList();
  });
});

class ToursApi {
  Future<void> addTour(Tour newTour) async {
    await FirebaseFirestore.instance.collection('tours').add(newTour.toJson());
  }
}

final toursApiProvider = Provider<ToursApi>((ref) {
  return ToursApi();
});
