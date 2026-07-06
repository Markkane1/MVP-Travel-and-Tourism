// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'staff_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_StaffModel _$StaffModelFromJson(Map<String, dynamic> json) => _StaffModel(
  id: json['id'] as String? ?? '',
  email: json['email'] as String? ?? '',
  role: json['role'] as String? ?? 'admin',
  isActive: json['isActive'] as bool? ?? true,
  createdAt: _timestampFromJson(json['createdAt']),
  updatedAt: _timestampFromJson(json['updatedAt']),
);

Map<String, dynamic> _$StaffModelToJson(_StaffModel instance) =>
    <String, dynamic>{
      'email': instance.email,
      'role': instance.role,
      'isActive': instance.isActive,
      'createdAt': _timestampToJson(instance.createdAt),
      'updatedAt': _timestampToJson(instance.updatedAt),
    };
