class NotificationItem {
  final String id;
  final String title;
  final String body;
  final String type;
  final String deepLink;
  final bool read;
  final DateTime createdAt;

  const NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.deepLink,
    required this.read,
    required this.createdAt,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> data) {
    return NotificationItem(
      id: data['id'] as String? ?? '',
      title: data['title'] ?? '',
      body: data['body'] ?? data['message'] ?? '',
      type: data['type'] ?? 'system',
      deepLink: data['deepLink'] ?? '',
      read: data['read'] ?? data['isRead'] ?? false,
      createdAt: data['createdAt'] is String
          ? DateTime.tryParse(data['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
