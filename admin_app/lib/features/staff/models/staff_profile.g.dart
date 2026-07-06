// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'staff_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_StaffProfile _$StaffProfileFromJson(Map<String, dynamic> json) =>
    _StaffProfile(
      uid: json['uid'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      isActive: json['isActive'] as bool? ?? true,
      updatedAt: _timestampFromJson(json['updatedAt']),
    );

Map<String, dynamic> _$StaffProfileToJson(_StaffProfile instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'email': instance.email,
      'role': instance.role,
      'isActive': instance.isActive,
      'updatedAt': _timestampToJson(instance.updatedAt),
    };
