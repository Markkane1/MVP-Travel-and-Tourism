import 'package:freezed_annotation/freezed_annotation.dart';

part 'audit_model.freezed.dart';
part 'audit_model.g.dart';

@freezed
abstract class AuditModel with _$AuditModel {
  const AuditModel._();

  const factory AuditModel({
    @JsonKey(includeToJson: false) @Default('') String id,
    @Default('') String actorUid,
    @Default('') String actorEmail,
    @Default('') String actorRole,
    @Default('') String action,
    @Default('') String targetType,
    @Default('') String targetId,
    @Default('') String summary,
    Map<String, dynamic>? before,
    Map<String, dynamic>? after,
    String? reason,
    @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
    DateTime? createdAt,
  }) = _AuditModel;

  factory AuditModel.fromJson(Map<String, dynamic> json) =>
      _$AuditModelFromJson(json);
}

DateTime? _timestampFromJson(dynamic value) {
  if (value is String) return DateTime.tryParse(value);
  if (value is DateTime) return value;
  return null;
}

dynamic _timestampToJson(DateTime? value) {
  return value?.toIso8601String();
}
