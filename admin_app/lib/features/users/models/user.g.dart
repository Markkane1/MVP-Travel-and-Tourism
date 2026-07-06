// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserModel _$UserModelFromJson(Map<String, dynamic> json) => _UserModel(
  id: json['id'] as String? ?? '',
  email: json['email'] as String? ?? '',
  displayName: json['displayName'] as String?,
  tier: json['tier'] as String? ?? 'base',
  loyaltyPoints: (json['loyaltyPoints'] as num?)?.toInt() ?? 0,
  conciergeId: json['conciergeId'] as String?,
  preferences: json['preferences'] as Map<String, dynamic>?,
  savedTours:
      (json['savedTours'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  createdAt: _timestampFromJson(json['createdAt']),
);

Map<String, dynamic> _$UserModelToJson(_UserModel instance) =>
    <String, dynamic>{
      'email': instance.email,
      'displayName': instance.displayName,
      'tier': instance.tier,
      'loyaltyPoints': instance.loyaltyPoints,
      'conciergeId': instance.conciergeId,
      'preferences': instance.preferences,
      'savedTours': instance.savedTours,
      'createdAt': _timestampToJson(instance.createdAt),
    };
