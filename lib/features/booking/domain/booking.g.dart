// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booking.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TourSnapshot _$TourSnapshotFromJson(Map<String, dynamic> json) =>
    _TourSnapshot(
      title: json['title'] as String,
      heroImageUrl: json['heroImageUrl'] as String,
      destination: json['destination'] as String,
    );

Map<String, dynamic> _$TourSnapshotToJson(_TourSnapshot instance) =>
    <String, dynamic>{
      'title': instance.title,
      'heroImageUrl': instance.heroImageUrl,
      'destination': instance.destination,
    };

_Booking _$BookingFromJson(Map<String, dynamic> json) => _Booking(
  id: json['id'] as String,
  userId: json['userId'] as String,
  tourId: json['tourId'] as String,
  tourSnapshot: TourSnapshot.fromJson(
    json['tourSnapshot'] as Map<String, dynamic>,
  ),
  tourDate: DateTime.parse(json['tourDate'] as String),
  adults: (json['adults'] as num).toInt(),
  children: (json['children'] as num).toInt(),
  privateVehicle: json['privateVehicle'] as bool,
  groupSizeOption: json['groupSizeOption'] as String,
  pickupLocation: json['pickupLocation'] as String,
  specialRequests: json['specialRequests'] as String?,
  totalPrice: (json['totalPrice'] as num).toDouble(),
  currency: json['currency'] as String,
  status: json['status'] as String,
  stripePaymentIntentId: json['stripePaymentIntentId'] as String?,
  bookingReferenceCode: json['bookingReferenceCode'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$BookingToJson(_Booking instance) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'tourId': instance.tourId,
  'tourSnapshot': instance.tourSnapshot,
  'tourDate': instance.tourDate.toIso8601String(),
  'adults': instance.adults,
  'children': instance.children,
  'privateVehicle': instance.privateVehicle,
  'groupSizeOption': instance.groupSizeOption,
  'pickupLocation': instance.pickupLocation,
  'specialRequests': instance.specialRequests,
  'totalPrice': instance.totalPrice,
  'currency': instance.currency,
  'status': instance.status,
  'stripePaymentIntentId': instance.stripePaymentIntentId,
  'bookingReferenceCode': instance.bookingReferenceCode,
  'createdAt': instance.createdAt.toIso8601String(),
};
