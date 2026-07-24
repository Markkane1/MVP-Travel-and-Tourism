import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
abstract class UserModel with _$UserModel {
  const UserModel._();

  const factory UserModel({
    @JsonKey(includeToJson: false) @Default('') String id,
    @Default('') String email,
    String? displayName,
    @Default('base') String tier,
    @Default(0) int loyaltyPoints,
    String? conciergeId,
    Map<String, dynamic>? preferences,
    @Default([]) List<String> savedTours,
    @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
    DateTime? createdAt,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

}

DateTime? _timestampFromJson(dynamic value) {
  if (value is String) return DateTime.tryParse(value);
  if (value is DateTime) return value;
  return null;
}

dynamic _timestampToJson(DateTime? value) {
  return value?.toIso8601String();
}
