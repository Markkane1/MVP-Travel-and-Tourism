import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'staff_profile.freezed.dart';
part 'staff_profile.g.dart';

@freezed
class StaffProfile with _$StaffProfile {
  const factory StaffProfile({
    required String uid,
    required String email,
    required String role,
    @Default(true) bool isActive,
    @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
    DateTime? updatedAt,
  }) = _StaffProfile;

  factory StaffProfile.fromJson(Map<String, dynamic> json) => _$StaffProfileFromJson(json);
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
