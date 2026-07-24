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

  factory ConciergeMessage.fromJson(Map<String, dynamic> data) {
    return ConciergeMessage(
      id: data['id'] as String? ?? '',
      senderId: data['senderId'] ?? '',
      senderType: _senderType(data['senderType'] ?? data['senderRole']),
      text: data['text'] ?? data['content'] ?? '',
      attachmentUrl: data['attachmentUrl'],
      createdAt: data['createdAt'] is String
          ? DateTime.tryParse(data['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

String _senderType(dynamic value) {
  final role = value?.toString().toLowerCase() ?? '';
  return role == 'customer' || role == 'user' ? 'user' : 'concierge';
}
