import 'package:cloud_firestore/cloud_firestore.dart';

/// Representation model of a concierge message.
class ConciergeMessage {
  final String id;
  final String senderId;
  final String senderType; // 'user' or 'concierge'
  final String text;
  final String? attachmentUrl;
  final DateTime createdAt;

  const ConciergeMessage({
    required this.id,
    required this.senderId,
    required this.senderType,
    required this.text,
    this.attachmentUrl,
    required this.createdAt,
  });

  factory ConciergeMessage.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final timestamp = data['createdAt'] as Timestamp?;
    return ConciergeMessage(
      id: doc.id,
      senderId: data['senderId'] ?? '',
      senderType: data['senderType'] ?? 'user',
      text: data['text'] ?? '',
      attachmentUrl: data['attachmentUrl'],
      createdAt: timestamp?.toDate() ?? DateTime.now(),
    );
  }
}
