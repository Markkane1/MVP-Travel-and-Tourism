import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  factory Service.fromFirestore(Map<String, dynamic> data, String documentId) {
    return Service.fromJson({...data, 'id': documentId});
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
