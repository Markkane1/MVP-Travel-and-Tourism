import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'concierge_thread.freezed.dart';
part 'concierge_thread.g.dart';

@freezed
abstract class ConciergeThread with _$ConciergeThread {
  const ConciergeThread._();

  const factory ConciergeThread({
    @JsonKey(includeToJson: false) @Default('') String id,
    @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
    DateTime? lastMessageAt,
    String? lastMessageText,
    String? lastMessageSender,
    @Default(false) bool isTyping,
    @Default(false) bool hasUnreadUserMessage,
  }) = _ConciergeThread;

  factory ConciergeThread.fromJson(Map<String, dynamic> json) =>
      _$ConciergeThreadFromJson(json);

  factory ConciergeThread.fromFirestore(
    Map<String, dynamic> data,
    String documentId,
  ) {
    return ConciergeThread.fromJson({...data, 'id': documentId});
  }
}

@freezed
abstract class ConciergeMessage with _$ConciergeMessage {
  const ConciergeMessage._();

  const factory ConciergeMessage({
    @JsonKey(includeToJson: false) @Default('') String id,
    required String senderId,
    required String senderType, // 'user' or 'concierge'
    required String text,
    @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
    DateTime? createdAt,
  }) = _ConciergeMessage;

  factory ConciergeMessage.fromJson(Map<String, dynamic> json) =>
      _$ConciergeMessageFromJson(json);

  factory ConciergeMessage.fromFirestore(
    Map<String, dynamic> data,
    String documentId,
  ) {
    return ConciergeMessage.fromJson({...data, 'id': documentId});
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
