import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/service.dart';

final servicesStreamProvider = StreamProvider.autoDispose<List<Service>>((ref) {
  return FirebaseFirestore.instance
      .collection('services')
      .orderBy('sortOrder')
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) => Service.fromFirestore(doc.data(), doc.id)).toList();
  });
});

class ServicesApi {
  Future<void> addService(Service newService) async {
    await FirebaseFirestore.instance.collection('services').add(newService.toJson());
  }

  Future<void> updateService(Service service) async {
    final data = service.toJson();
    data['updatedAt'] = FieldValue.serverTimestamp();
    await FirebaseFirestore.instance.collection('services').doc(service.id).update(data);
  }

  Future<void> archiveService(String serviceId, String archivedBy) async {
    await FirebaseFirestore.instance.collection('services').doc(serviceId).update({
      'isActive': false,
      'archivedAt': FieldValue.serverTimestamp(),
      'archivedBy': archivedBy,
    });
  }
}

final servicesApiProvider = Provider<ServicesApi>((ref) {
  return ServicesApi();
});
