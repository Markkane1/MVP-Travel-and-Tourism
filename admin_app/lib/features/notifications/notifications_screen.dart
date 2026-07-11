import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'providers/notifications_providers.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  final _typeController = TextEditingController();
  final _deepLinkController = TextEditingController();
  final _targetUserIdController = TextEditingController();

  String _targetType = 'single';
  String _cohortTier = 'base';
  bool _isSending = false;

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    _typeController.dispose();
    _deepLinkController.dispose();
    _targetUserIdController.dispose();
    super.dispose();
  }

  Future<void> _sendNotification() async {
    final title = _titleController.text.trim();
    final body = _bodyController.text.trim();
    if (title.isEmpty || body.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Title and Body are required.')),
      );
      return;
    }

    if (_targetType == 'single' &&
        _targetUserIdController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Target User ID is required for single target.'),
        ),
      );
      return;
    }

    setState(() => _isSending = true);
    try {
      await ref
          .read(notificationsApiProvider)
          .sendNotification(
            targetType: _targetType,
            title: title,
            body: body,
            type: _typeController.text.trim(),
            deepLink: _deepLinkController.text.trim(),
            targetUserId: _targetUserIdController.text.trim(),
            cohortTier: _cohortTier,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notification Dispatched Successfully!'),
          ),
        );
        _titleController.clear();
        _bodyController.clear();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: \$e')));
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Notification Composer',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: theme.colorScheme.outlineVariant),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Target Audience',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            initialValue: _targetType,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'single',
                                child: Text('Single User'),
                              ),
                              DropdownMenuItem(
                                value: 'cohort',
                                child: Text('Filtered Cohort (Tier)'),
                              ),
                              DropdownMenuItem(
                                value: 'all',
                                child: Text('All Users'),
                              ),
                            ],
                            onChanged: (val) {
                              if (val != null) {
                                setState(() => _targetType = val);
                              }
                            },
                          ),
                          const SizedBox(height: 16),
                          if (_targetType == 'single')
                            TextField(
                              controller: _targetUserIdController,
                              decoration: const InputDecoration(
                                labelText: 'Target User ID',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          if (_targetType == 'cohort')
                            DropdownButtonFormField<String>(
                              initialValue: _cohortTier,
                              decoration: const InputDecoration(
                                labelText: 'Target Tier',
                                border: OutlineInputBorder(),
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: 'base',
                                  child: Text('Base'),
                                ),
                                DropdownMenuItem(
                                  value: 'gold',
                                  child: Text('Gold'),
                                ),
                                DropdownMenuItem(
                                  value: 'platinum',
                                  child: Text('Platinum'),
                                ),
                              ],
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() => _cohortTier = val);
                                }
                              },
                            ),
                          const Divider(height: 48),
                          const Text(
                            'Message Content',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _titleController,
                            decoration: const InputDecoration(
                              labelText: 'Title',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _bodyController,
                            maxLines: 3,
                            decoration: const InputDecoration(
                              labelText: 'Body',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _typeController,
                                  decoration: const InputDecoration(
                                    labelText: 'Type (e.g., promo, system)',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: TextField(
                                  controller: _deepLinkController,
                                  decoration: const InputDecoration(
                                    labelText: 'Deep Link (optional)',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton.icon(
                              icon: _isSending
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Icons.send),
                              label: const Text('Dispatch Notification'),
                              onPressed: _isSending ? null : _sendNotification,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const VerticalDivider(width: 1),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sent History',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('admin_audit_logs')
                          .where('action', isEqualTo: 'adminSendNotification')
                          .orderBy('createdAt', descending: true)
                          .limit(20)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        if (snapshot.hasError) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: SelectableText(
                                'Error: ${snapshot.error}',
                                style: const TextStyle(color: Colors.red),
                              ),
                            ),
                          );
                        }
                        final docs = snapshot.data?.docs ?? [];
                        if (docs.isEmpty) {
                          return const Center(child: Text('No history found.'));
                        }
                        return ListView.builder(
                          itemCount: docs.length,
                          itemBuilder: (context, index) {
                            final data =
                                docs[index].data() as Map<String, dynamic>;
                            final payload =
                                data['payload'] as Map<String, dynamic>? ?? {};
                            final ts = data['createdAt'] as Timestamp?;
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(
                                  color: theme.colorScheme.outlineVariant,
                                ),
                              ),
                              child: ListTile(
                                title: Text(
                                  payload['title'] ?? 'No Title',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 4),
                                    Text("Target: ${data['targetType']}"),
                                    Text("Sent by: ${data['actorEmail']}"),
                                    if (ts != null)
                                      Text(
                                        ts.toDate().toString(),
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
