import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart' hide Result;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../auth/auth.dart';
import '../domain/payment_method_item.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/utils/safe_stream.dart';
import '../../../../core/errors/app_exception.dart';

part 'profile_repository.g.dart';

Map<String, dynamic> normalizeProfileData(Map<String, dynamic>? data) {
  final profile = Map<String, dynamic>.from(data ?? {});

  profile['displayName'] = profile['displayName'] is String &&
          (profile['displayName'] as String).isNotEmpty
      ? profile['displayName'] as String
      : 'Guest';
  profile['email'] = profile['email'] is String ? profile['email'] as String : '';
  profile['loyaltyPoints'] =
      profile['loyaltyPoints'] is num ? profile['loyaltyPoints'] as num : 0;
  profile['milesTraveled'] =
      profile['milesTraveled'] is num ? profile['milesTraveled'] as num : 0;
  profile['tier'] = profile['tier'] is String &&
          (profile['tier'] as String).isNotEmpty
      ? profile['tier'] as String
      : 'Standard';
  profile['photoUrl'] =
      profile['photoUrl'] is String ? profile['photoUrl'] as String : '';

  final notificationPrefs = profile['notificationPrefs'] is Map
      ? Map<String, dynamic>.from(profile['notificationPrefs'] as Map)
      : <String, dynamic>{};
  notificationPrefs['bookingUpdates'] =
      notificationPrefs['bookingUpdates'] is bool
          ? notificationPrefs['bookingUpdates'] as bool
          : true;
  notificationPrefs['promotions'] = notificationPrefs['promotions'] is bool
      ? notificationPrefs['promotions'] as bool
      : true;
  notificationPrefs['conciergeMessages'] =
      notificationPrefs['conciergeMessages'] is bool
          ? notificationPrefs['conciergeMessages'] as bool
          : true;
  profile['notificationPrefs'] = notificationPrefs;

  final preferences = profile['preferences'] is Map
      ? Map<String, dynamic>.from(profile['preferences'] as Map)
      : <String, dynamic>{};
  preferences['dietary'] = preferences['dietary'] is String
      ? preferences['dietary'] as String
      : '';
  preferences['seat'] = preferences['seat'] is String ? preferences['seat'] as String : '';
  preferences['hotelClass'] = preferences['hotelClass'] is String
      ? preferences['hotelClass'] as String
      : '';
  profile['preferences'] = preferences;

  return profile;
}

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
        .map((doc) => normalizeProfileData(doc.data()))
        .mapAppException('Failed to load profile');
  }

  /// Updates display name and photo url.
  Future<Result<void>> updateProfile({
    required String uid,
    required String name,
    required String photoUrl,
  }) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'displayName': name,
        'photoUrl': photoUrl,
      });
      return const Result.success(null);
    } catch (e) {
      return Result.failure(
        AppException.unknown('Failed to update profile: ${e.toString()}'),
      );
    }
  }

  /// Updates a single notification preference under notificationPrefs map.
  Future<Result<void>> updateNotificationPreference({
    required String uid,
    required String key,
    required bool value,
  }) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'notificationPrefs.$key': value,
      });
      return const Result.success(null);
    } catch (e) {
      return Result.failure(
        AppException.unknown('Failed to update preference: ${e.toString()}'),
      );
    }
  }

  /// Saves travel preferences.
  Future<Result<void>> saveTravelPreferences({
    required String uid,
    required String dietary,
    required String seat,
    required String hotelClass,
  }) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'preferences': {
          'dietary': dietary,
          'seat': seat,
          'hotelClass': hotelClass,
        },
      });
      return const Result.success(null);
    } catch (e) {
      return Result.failure(
        AppException.unknown('Failed to save preferences: ${e.toString()}'),
      );
    }
  }

  /// Streams saved payment methods.
  Stream<List<PaymentMethodItem>> watchPaymentMethods(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('paymentMethods')
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((doc) => PaymentMethodItem.fromFirestore(doc))
              .toList(),
        )
        .mapAppException('Failed to load payment methods');
  }

  /// Deletes a payment method.
  Future<Result<void>> deletePaymentMethod({
    required String uid,
    required String methodId,
  }) async {
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('paymentMethods')
          .doc(methodId)
          .delete();
      return const Result.success(null);
    } catch (e) {
      return Result.failure(
        AppException.unknown(
          'Failed to delete payment method: ${e.toString()}',
        ),
      );
    }
  }

  /// Saves a payment method card, optionally unsetting other defaults.
  Future<Result<void>> savePaymentMethod({
    required String uid,
    required String brand,
    required String last4,
    required bool isDefault,
  }) async {
    try {
      final collection = _firestore
          .collection('users')
          .doc(uid)
          .collection('paymentMethods');

      if (isDefault) {
        final defaults = await collection
            .where('isDefault', isEqualTo: true)
            .get();
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
      });
      return const Result.success(null);
    } catch (e) {
      return Result.failure(
        AppException.unknown('Failed to save card: ${e.toString()}'),
      );
    }
  }

  /// Calls Cloud Function to delete user-related Firestore data.
  Future<Result<void>> cleanupUserData() async {
    try {
      await _functions.httpsCallable('cleanupUserData').call();
      return const Result.success(null);
    } catch (e) {
      return Result.failure(
        AppException.unknown('Firestore user cleanup failed: ${e.toString()}'),
      );
    }
  }
}

@riverpod
ProfileRepository profileRepository(Ref ref) {
  return ProfileRepository(
    FirebaseFirestore.instance,
    FirebaseFunctions.instance,
  );
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
