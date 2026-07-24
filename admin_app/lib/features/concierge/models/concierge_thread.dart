import 'package:freezed_annotation/freezed_annotation.dart';

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

}

DateTime? _timestampFromJson(dynamic value) {
  if (value is String) return DateTime.tryParse(value);
  if (value is DateTime) return value;
  return null;
}

dynamic _timestampToJson(DateTime? value) {
  return value?.toIso8601String();
}
