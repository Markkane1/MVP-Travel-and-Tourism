import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'staff_model.freezed.dart';
part 'staff_model.g.dart';

@freezed
abstract class StaffModel with _$StaffModel {
  const StaffModel._();

  const factory StaffModel({
    @JsonKey(includeToJson: false) @Default('') String id,
    @Default('') String email,
    @Default('admin') String role,
    @Default(true) bool isActive,
    @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson) DateTime? createdAt,
    @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson) DateTime? updatedAt,
  }) = _StaffModel;

  factory StaffModel.fromJson(Map<String, dynamic> json) => _$StaffModelFromJson(json);

  factory StaffModel.fromFirestore(Map<String, dynamic> data, String documentId) {
    return StaffModel.fromJson({
      ...data,
      'id': documentId,
    });
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
