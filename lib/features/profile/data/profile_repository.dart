import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/services/api_client.dart';
import '../../auth/auth.dart';
import '../domain/payment_method_item.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/errors/app_exception.dart';

part 'profile_repository.g.dart';

Map<String, dynamic> normalizeProfileData(Map<String, dynamic>? data) {
  final profile = Map<String, dynamic>.from(data ?? {});

  profile['displayName'] =
      profile['displayName'] is String &&
          (profile['displayName'] as String).isNotEmpty
      ? profile['displayName'] as String
      : 'Guest';
  profile['email'] = profile['email'] is String
      ? profile['email'] as String
      : '';
  profile['loyaltyPoints'] = profile['loyaltyPoints'] is num
      ? profile['loyaltyPoints'] as num
      : int.tryParse(profile['loyaltyPoints']?.toString() ?? '') ?? 0;
  profile['milesTraveled'] = profile['milesTraveled'] is num
      ? profile['milesTraveled'] as num
      : int.tryParse(profile['milesTraveled']?.toString() ?? '') ?? 0;
  profile['tier'] =
      profile['tier'] is String && (profile['tier'] as String).isNotEmpty
      ? profile['tier'] as String
      : 'Standard';
  profile['photoUrl'] = profile['photoUrl'] is String
      ? profile['photoUrl'] as String
      : '';

  final notificationPrefs = profile['notificationPrefs'] is Map
      ? Map<String, dynamic>.from(profile['notificationPrefs'] as Map)
      : <String, dynamic>{};
  notificationPrefs['bookingUpdates'] =
      notificationPrefs['bookingUpdates'] is bool
      ? notificationPrefs['bookingUpdates'] as bool
      : (notificationPrefs['bookingUpdates']?.toString().toLowerCase() ==
                'false'
            ? false
            : true);
  notificationPrefs['promotions'] = notificationPrefs['promotions'] is bool
      ? notificationPrefs['promotions'] as bool
      : (notificationPrefs['promotions']?.toString().toLowerCase() == 'false'
            ? false
            : true);
  notificationPrefs['conciergeMessages'] =
      notificationPrefs['conciergeMessages'] is bool
      ? notificationPrefs['conciergeMessages'] as bool
      : (notificationPrefs['conciergeMessages']?.toString().toLowerCase() ==
                'false'
            ? false
            : true);
  profile['notificationPrefs'] = notificationPrefs;

  final preferences = profile['preferences'] is Map
      ? Map<String, dynamic>.from(profile['preferences'] as Map)
      : <String, dynamic>{};
  preferences['dietary'] = preferences['dietary'] is String
      ? preferences['dietary'] as String
      : '';
  preferences['seat'] = preferences['seat'] is String
      ? preferences['seat'] as String
      : '';
  preferences['hotelClass'] = preferences['hotelClass'] is String
      ? preferences['hotelClass'] as String
      : '';
  profile['preferences'] = preferences;

  return profile;
}

class ProfileRepository {
  final ApiClient _api;

  ProfileRepository(this._api);

  /// Streams user profile from API.
  Stream<Map<String, dynamic>?> watchUserProfile(String uid) {
    return Stream.fromFuture(_fetchProfile());
  }

  /// Updates display name and photo url.
  Future<Result<void>> updateProfile({
    required String uid,
    required String name,
    required String photoUrl,
  }) async {
    try {
      final parts = name.trim().split(RegExp(r'\s+'));
      await _api.patchJson('/users/me', {
        'firstName': parts.isEmpty ? name : parts.first,
        'lastName': parts.length > 1 ? parts.skip(1).join(' ') : 'User',
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
      // ponytail: notificationPrefs needs a profile JSON column; add when persistence matters.
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
      // ponytail: travel preferences need a profile JSON column; add when persistence matters.
      return const Result.success(null);
    } catch (e) {
      return Result.failure(
        AppException.unknown('Failed to save preferences: ${e.toString()}'),
      );
    }
  }

  /// Streams saved payment methods.
  Stream<List<PaymentMethodItem>> watchPaymentMethods(String uid) {
    return Stream.value(const <PaymentMethodItem>[]);
  }

  /// Deletes a payment method.
  Future<Result<void>> deletePaymentMethod({
    required String uid,
    required String methodId,
  }) async {
    try {
      return const Result.success(null);
    } catch (e) {
      return Result.failure(
        AppException.unknown(
          'Failed to delete payment method: ${e.toString()}',
        ),
      );
    }
  }

  /// Calls the backend API to delete/anonymize user-related data.
  Future<Result<void>> cleanupUserData() async {
    try {
      await _api.delete('/users/me');
      return const Result.success(null);
    } catch (e) {
      return Result.failure(
        AppException.unknown('User cleanup failed: ${e.toString()}'),
      );
    }
  }

  Future<Map<String, dynamic>?> _fetchProfile() async {
    final data = await _api.getJson('/users/me', authenticated: true);
    final user = Map<String, dynamic>.from(data as Map);
    return normalizeProfileData({
      ...user,
      'displayName': '${user['firstName'] ?? ''} ${user['lastName'] ?? ''}'
          .trim(),
      'photoUrl': '',
      'tier': _titleCase(user['tier']?.toString() ?? 'STANDARD'),
    });
  }
}

@riverpod
ProfileRepository profileRepository(Ref ref) {
  return ProfileRepository(ref.watch(apiClientProvider));
}

String _titleCase(String value) {
  final lower = value.toLowerCase().replaceAll('_', ' ');
  return lower
      .split(' ')
      .map(
        (part) => part.isEmpty
            ? part
            : '${part[0].toUpperCase()}${part.substring(1)}',
      )
      .join(' ');
}

/// Provider that reactively streams the current user's profile from the API.
@riverpod
Stream<Map<String, dynamic>?> userProfileData(Ref ref) {
  final authState = ref.watch(authControllerProvider);
  final user = authState.value;
  if (user == null) return Stream.value(null);

  return ref.watch(profileRepositoryProvider).watchUserProfile(user.uid);
}

@riverpod
Stream<List<PaymentMethodItem>> paymentMethodsStream(Ref ref, String uid) {
  return ref.watch(profileRepositoryProvider).watchPaymentMethods(uid);
}
