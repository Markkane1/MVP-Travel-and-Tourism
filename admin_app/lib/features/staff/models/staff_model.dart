import 'package:freezed_annotation/freezed_annotation.dart';

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
    @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
    DateTime? createdAt,
    @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
    DateTime? updatedAt,
  }) = _StaffModel;

  factory StaffModel.fromJson(Map<String, dynamic> json) =>
      _$StaffModelFromJson(json);

}

DateTime? _timestampFromJson(dynamic value) {
  if (value is String) return DateTime.tryParse(value);
  if (value is DateTime) return value;
  return null;
}

dynamic _timestampToJson(DateTime? value) {
  return value?.toIso8601String();
}
