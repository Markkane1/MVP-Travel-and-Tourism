import 'package:freezed_annotation/freezed_annotation.dart';

part 'service.freezed.dart';
part 'service.g.dart';

@freezed
abstract class Service with _$Service {
  const Service._();

  const factory Service({
    @JsonKey(includeToJson: false) @Default('') String id,
    required String name,
    required String category,
    required String description,
    required double basePrice,
    required String currency,
    required String unitType,
    String? imageUrl,
    @Default(true) bool isActive,
    @Default(0) int sortOrder,
    @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
    DateTime? createdAt,
    @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
    DateTime? updatedAt,
    @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
    DateTime? archivedAt,
    String? archivedBy,
  }) = _Service;

  factory Service.fromJson(Map<String, dynamic> json) =>
      _$ServiceFromJson(json);

}

DateTime? _timestampFromJson(dynamic value) {
  if (value is String) return DateTime.tryParse(value);
  if (value is DateTime) return value;
  return null;
}

dynamic _timestampToJson(DateTime? value) {
  return value?.toIso8601String();
}
