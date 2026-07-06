// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'audit_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AuditModel _$AuditModelFromJson(Map<String, dynamic> json) => _AuditModel(
  id: json['id'] as String? ?? '',
  actorUid: json['actorUid'] as String? ?? '',
  actorEmail: json['actorEmail'] as String? ?? '',
  actorRole: json['actorRole'] as String? ?? '',
  action: json['action'] as String? ?? '',
  targetType: json['targetType'] as String? ?? '',
  targetId: json['targetId'] as String? ?? '',
  summary: json['summary'] as String? ?? '',
  before: json['before'] as Map<String, dynamic>?,
  after: json['after'] as Map<String, dynamic>?,
  reason: json['reason'] as String?,
  createdAt: _timestampFromJson(json['createdAt']),
);

Map<String, dynamic> _$AuditModelToJson(_AuditModel instance) =>
    <String, dynamic>{
      'actorUid': instance.actorUid,
      'actorEmail': instance.actorEmail,
      'actorRole': instance.actorRole,
      'action': instance.action,
      'targetType': instance.targetType,
      'targetId': instance.targetId,
      'summary': instance.summary,
      'before': instance.before,
      'after': instance.after,
      'reason': instance.reason,
      'createdAt': _timestampToJson(instance.createdAt),
    };
