// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'service.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Service _$ServiceFromJson(Map<String, dynamic> json) => _Service(
  id: json['id'] as String? ?? '',
  name: json['name'] as String,
  category: json['category'] as String,
  description: json['description'] as String,
  basePrice: (json['basePrice'] as num).toDouble(),
  currency: json['currency'] as String,
  unitType: json['unitType'] as String,
  imageUrl: json['imageUrl'] as String?,
  isActive: json['isActive'] as bool? ?? true,
  sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
  createdAt: _timestampFromJson(json['createdAt']),
  updatedAt: _timestampFromJson(json['updatedAt']),
  archivedAt: _timestampFromJson(json['archivedAt']),
  archivedBy: json['archivedBy'] as String?,
);

Map<String, dynamic> _$ServiceToJson(_Service instance) => <String, dynamic>{
  'name': instance.name,
  'category': instance.category,
  'description': instance.description,
  'basePrice': instance.basePrice,
  'currency': instance.currency,
  'unitType': instance.unitType,
  'imageUrl': instance.imageUrl,
  'isActive': instance.isActive,
  'sortOrder': instance.sortOrder,
  'createdAt': _timestampToJson(instance.createdAt),
  'updatedAt': _timestampToJson(instance.updatedAt),
  'archivedAt': _timestampToJson(instance.archivedAt),
  'archivedBy': instance.archivedBy,
};
