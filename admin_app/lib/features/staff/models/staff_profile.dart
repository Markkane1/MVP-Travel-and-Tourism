import 'package:freezed_annotation/freezed_annotation.dart';

part 'staff_profile.freezed.dart';
part 'staff_profile.g.dart';

@freezed
abstract class StaffProfile with _$StaffProfile {
  const factory StaffProfile({
    required String uid,
    required String email,
    required String role,
    @Default(true) bool isActive,
    @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
    DateTime? updatedAt,
  }) = _StaffProfile;

  factory StaffProfile.fromJson(Map<String, dynamic> json) =>
      _$StaffProfileFromJson(json);
}

DateTime? _timestampFromJson(dynamic value) {
  if (value is String) return DateTime.tryParse(value);
  if (value is DateTime) return value;
  return null;
}

dynamic _timestampToJson(DateTime? value) {
  return value?.toIso8601String();
}
