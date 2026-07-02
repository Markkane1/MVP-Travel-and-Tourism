import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A generic, feature-agnostic client wrapping Firestore CRUD and Stream methods.
class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  FirestoreService();

  /// Retrieves a single document by path and deserializes it.
  Future<T?> get<T>({
    required String path,
    required T Function(Map<String, dynamic> json) fromJson,
    required Map<String, dynamic> Function(T value) toJson,
  }) async {
    final docRef = _firestore
        .doc(path)
        .withConverter<T>(
          fromFirestore: (snapshot, _) => fromJson(snapshot.data() ?? {}),
          toFirestore: (value, _) => toJson(value),
        );
    final snapshot = await docRef.get();
    return snapshot.data();
  }

  /// Writes (set/merge) a document at the specified path.
  Future<void> set<T>({
    required String path,
    required T data,
    required Map<String, dynamic> Function(T value) toJson,
    bool merge = true,
  }) async {
    await _firestore.doc(path).set(toJson(data), SetOptions(merge: merge));
  }

  /// Updates existing fields inside a document at the path.
  Future<void> update({
    required String path,
    required Map<String, dynamic> data,
  }) async {
    await _firestore.doc(path).update(data);
  }

  /// Deletes the document at the specified path.
  Future<void> delete({required String path}) async {
    await _firestore.doc(path).delete();
  }

  /// Exposes a real-time stream of a document at the path.
  Stream<T?> stream<T>({
    required String path,
    required T Function(Map<String, dynamic> json) fromJson,
    required Map<String, dynamic> Function(T value) toJson,
  }) {
    final docRef = _firestore
        .doc(path)
        .withConverter<T>(
          fromFirestore: (snapshot, _) => fromJson(snapshot.data() ?? {}),
          toFirestore: (value, _) => toJson(value),
        );
    return docRef.snapshots().map((snapshot) => snapshot.data());
  }

  /// Retrieves all documents inside a collection, with optional sorting/queries.
  Future<List<T>> getCollection<T>({
    required String path,
    required T Function(Map<String, dynamic> json) fromJson,
    required Map<String, dynamic> Function(T value) toJson,
    Query<T> Function(Query<T> query)? queryBuilder,
  }) async {
    Query<T> query = _firestore
        .collection(path)
        .withConverter<T>(
          fromFirestore: (snapshot, _) => fromJson(snapshot.data() ?? {}),
          toFirestore: (value, _) => toJson(value),
        );
    if (queryBuilder != null) {
      query = queryBuilder(query);
    }
    final snapshot = await query.get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  /// Exposes a real-time stream of a collection, with optional sorting/queries.
  Stream<List<T>> streamCollection<T>({
    required String path,
    required T Function(Map<String, dynamic> json) fromJson,
    required Map<String, dynamic> Function(T value) toJson,
    Query<T> Function(Query<T> query)? queryBuilder,
  }) {
    Query<T> query = _firestore
        .collection(path)
        .withConverter<T>(
          fromFirestore: (snapshot, _) => fromJson(snapshot.data() ?? {}),
          toFirestore: (value, _) => toJson(value),
        );
    if (queryBuilder != null) {
      query = queryBuilder(query);
    }
    return query.snapshots().map(
      (snapshot) => snapshot.docs.map((doc) => doc.data()).toList(),
    );
  }
}

/// Provider for the FirestoreService instance.
final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});
