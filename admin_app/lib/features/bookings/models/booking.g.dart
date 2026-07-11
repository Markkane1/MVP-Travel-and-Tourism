// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booking.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Booking _$BookingFromJson(Map<String, dynamic> json) => _Booking(
  id: json['id'] as String? ?? '',
  userId: json['userId'] as String,
  tourId: json['tourId'] as String,
  status: json['status'] as String,
  totalPrice: (json['totalPrice'] as num).toDouble(),
  currency: json['currency'] as String? ?? 'USD',
  bookingReferenceCode: json['bookingReferenceCode'] as String?,
  refunded: json['refunded'] as bool? ?? false,
  refundReason: json['refundReason'] as String?,
  adminNotes: json['adminNotes'] as String?,
  lastAdminActionBy: json['lastAdminActionBy'] as String?,
  tourSnapshot: json['tourSnapshot'] as Map<String, dynamic>?,
  participantCounts: json['participantCounts'] as Map<String, dynamic>?,
  paymentReferences: json['paymentReferences'] as Map<String, dynamic>?,
  bookingDate: _timestampFromJson(json['bookingDate']),
  refundedAt: _timestampFromJson(json['refundedAt']),
  lastAdminActionAt: _timestampFromJson(json['lastAdminActionAt']),
  createdAt: _timestampFromJson(json['createdAt']),
);

Map<String, dynamic> _$BookingToJson(_Booking instance) => <String, dynamic>{
  'userId': instance.userId,
  'tourId': instance.tourId,
  'status': instance.status,
  'totalPrice': instance.totalPrice,
  'currency': instance.currency,
  'bookingReferenceCode': instance.bookingReferenceCode,
  'refunded': instance.refunded,
  'refundReason': instance.refundReason,
  'adminNotes': instance.adminNotes,
  'lastAdminActionBy': instance.lastAdminActionBy,
  'tourSnapshot': instance.tourSnapshot,
  'participantCounts': instance.participantCounts,
  'paymentReferences': instance.paymentReferences,
  'bookingDate': _timestampToJson(instance.bookingDate),
  'refundedAt': _timestampToJson(instance.refundedAt),
  'lastAdminActionAt': _timestampToJson(instance.lastAdminActionAt),
  'createdAt': _timestampToJson(instance.createdAt),
};
