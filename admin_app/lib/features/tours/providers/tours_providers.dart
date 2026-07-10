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

  Future<void> updateTour(Tour updatedTour) async {
    await FirebaseFirestore.instance.collection('tours').doc(updatedTour.id).update(updatedTour.toJson());
  }

  Future<void> deleteTour(String tourId) async {
    // For archive, we could set a flag. We'll just hard delete for now to make it compile, 
    // or set a flag in firestore directly without needing the freezed model to strictly have it yet.
    await FirebaseFirestore.instance.collection('tours').doc(tourId).update({'isActive': false});
  }
}

final toursApiProvider = Provider<ToursApi>((ref) {
  return ToursApi();
});
