import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  factory AuditModel.fromFirestore(
    Map<String, dynamic> data,
    String documentId,
  ) {
    return AuditModel.fromJson({...data, 'id': documentId});
  }
}

DateTime? _timestampFromJson(dynamic value) {
  if (value is Timestamp) {
    return value.toDate();
  }
  return null;
}

dynamic _timestampToJson(DateTime? value) {
  if (value == null) return null;
  return Timestamp.fromDate(value);
}
