// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'concierge_thread.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ConciergeThread _$ConciergeThreadFromJson(Map<String, dynamic> json) =>
    _ConciergeThread(
      id: json['id'] as String? ?? '',
      lastMessageAt: _timestampFromJson(json['lastMessageAt']),
      lastMessageText: json['lastMessageText'] as String?,
      lastMessageSender: json['lastMessageSender'] as String?,
      isTyping: json['isTyping'] as bool? ?? false,
      hasUnreadUserMessage: json['hasUnreadUserMessage'] as bool? ?? false,
    );

Map<String, dynamic> _$ConciergeThreadToJson(_ConciergeThread instance) =>
    <String, dynamic>{
      'lastMessageAt': _timestampToJson(instance.lastMessageAt),
      'lastMessageText': instance.lastMessageText,
      'lastMessageSender': instance.lastMessageSender,
      'isTyping': instance.isTyping,
      'hasUnreadUserMessage': instance.hasUnreadUserMessage,
    };

_ConciergeMessage _$ConciergeMessageFromJson(Map<String, dynamic> json) =>
    _ConciergeMessage(
      id: json['id'] as String? ?? '',
      senderId: json['senderId'] as String,
      senderType: json['senderType'] as String,
      text: json['text'] as String,
      createdAt: _timestampFromJson(json['createdAt']),
    );

Map<String, dynamic> _$ConciergeMessageToJson(_ConciergeMessage instance) =>
    <String, dynamic>{
      'senderId': instance.senderId,
      'senderType': instance.senderType,
      'text': instance.text,
      'createdAt': _timestampToJson(instance.createdAt),
    };
