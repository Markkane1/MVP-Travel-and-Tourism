import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart' hide Result;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../auth/auth.dart';
import '../domain/payment_method_item.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/errors/app_exception.dart';

part 'profile_repository.g.dart';

class ProfileRepository {
  final FirebaseFirestore _firestore;
  final FirebaseFunctions _functions;

  ProfileRepository(this._firestore, this._functions);

  /// Streams user profile from Firestore.
  Stream<Map<String, dynamic>?> watchUserProfile(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((doc) => doc.data());
  }

  /// Updates display name and photo url.
  Future<void> updateProfile({
    required String uid,
    required String name,
    required String photoUrl,
  }) async {
    await _firestore.collection('users').doc(uid).update({
      'displayName': name,
      'photoUrl': photoUrl,
    });
  }

  /// Updates a single notification preference under notificationPrefs map.
  Future<void> updateNotificationPreference({
    required String uid,
    required String key,
    required bool value,
  }) async {
    await _firestore.collection('users').doc(uid).update({
      'notificationPrefs.$key': value,
    });
  }

  /// Saves travel preferences.
  Future<void> saveTravelPreferences({
    required String uid,
    required String dietary,
    required String seat,
    required String hotelClass,
  }) async {
    await _firestore.collection('users').doc(uid).update({
      'preferences': {
        'dietary': dietary,
        'seat': seat,
        'hotelClass': hotelClass,
      }
    });
  }

  /// Streams saved payment methods.
  Stream<List<PaymentMethodItem>> watchPaymentMethods(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('paymentMethods')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => PaymentMethodItem.fromFirestore(doc))
            .toList());
  }

  /// Deletes a payment method.
  Future<void> deletePaymentMethod({
    required String uid,
    required String methodId,
  }) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('paymentMethods')
        .doc(methodId)
        .delete();
  }

  /// Saves a payment method card, optionally unsetting other defaults.
  Future<void> savePaymentMethod({
    required String uid,
    required String brand,
    required String last4,
    required bool isDefault,
  }) async {
    final collection = _firestore
        .collection('users')
        .doc(uid)
        .collection('paymentMethods');

    if (isDefault) {
      final defaults = await collection.where('isDefault', isEqualTo: true).get();
      final batch = _firestore.batch();
      for (var doc in defaults.docs) {
        batch.update(doc.reference, {'isDefault': false});
      }
      await batch.commit();
    }

    await collection.add({
      'brand': brand,
      'last4': last4,
      'isDefault': isDefault,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Calls Cloud Function to delete user-related Firestore data.
  Future<Result<void>> cleanupUserData() async {
    try {
      await _functions.httpsCallable('cleanupUserData').call();
      return const Result.success(null);
    } catch (e) {
      return Result.failure(AppException.unknown('Firestore user cleanup failed: ${e.toString()}'));
    }
  }
}

@riverpod
ProfileRepository profileRepository(Ref ref) {
  return ProfileRepository(FirebaseFirestore.instance, FirebaseFunctions.instance);
}

/// Provider that reactively streams the current user's profile document from Firestore.
@riverpod
Stream<Map<String, dynamic>?> userFirestoreData(Ref ref) {
  final authState = ref.watch(authControllerProvider);
  final user = authState.value;
  if (user == null) return Stream.value(null);

  return ref.watch(profileRepositoryProvider).watchUserProfile(user.uid);
}

@riverpod
Stream<List<PaymentMethodItem>> paymentMethodsStream(Ref ref, String uid) {
  return ref.watch(profileRepositoryProvider).watchPaymentMethods(uid);
}
