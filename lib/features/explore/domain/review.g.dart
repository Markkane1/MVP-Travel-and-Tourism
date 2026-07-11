// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Review _$ReviewFromJson(Map<String, dynamic> json) => _Review(
  id: json['id'] as String,
  userName: json['userName'] as String,
  userPhotoUrl: json['userPhotoUrl'] as String,
  overallRating: (json['overallRating'] as num).toDouble(),
  comment: json['comment'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$ReviewToJson(_Review instance) => <String, dynamic>{
  'id': instance.id,
  'userName': instance.userName,
  'userPhotoUrl': instance.userPhotoUrl,
  'overallRating': instance.overallRating,
  'comment': instance.comment,
  'createdAt': instance.createdAt.toIso8601String(),
};
