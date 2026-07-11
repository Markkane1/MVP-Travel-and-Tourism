import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/concierge_providers.dart';

class ConciergeScreen extends ConsumerStatefulWidget {
  const ConciergeScreen({super.key});

  @override
  ConsumerState<ConciergeScreen> createState() => _ConciergeScreenState();
}

class _ConciergeScreenState extends ConsumerState<ConciergeScreen> {
  String? _selectedUserId;

  @override
  Widget build(BuildContext context) {
    final threadsAsync = ref.watch(conciergeThreadsStreamProvider);
    final theme = Theme.of(context);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Concierge Operations',
              style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Row(
                children: [
                  // Left Pane: Thread List
                  Expanded(
                    flex: 1,
                    child: Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: theme.colorScheme.outlineVariant),
                      ),
                      child: threadsAsync.when(
                        loading: () => const Center(child: CircularProgressIndicator()),
                        error: (err, stack) => Center(child: Text('Error: $err')),
                        data: (threads) {
                          if (threads.isEmpty) return const Center(child: Text('No active threads.'));
                          return ListView.builder(
                            itemCount: threads.length,
                            itemBuilder: (context, index) {
                              final thread = threads[index];
                              final isSelected = thread.id == _selectedUserId;
                              return ListTile(
                                title: Text('User ${thread.id.substring(0, 8)}...'),
                                subtitle: Text(
                                  thread.lastMessageText ?? 'No messages yet',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                selected: isSelected,
                                selectedTileColor: theme.colorScheme.primaryContainer,
                                onTap: () => setState(() => _selectedUserId = thread.id),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                  // Right Pane: Thread Detail
                  Expanded(
                    flex: 2,
                    child: Card(
                      elevation: 0,
                      clipBehavior: Clip.antiAlias,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: theme.colorScheme.outlineVariant),
                      ),
                      child: _selectedUserId == null
                          ? const Center(child: Text('Select a thread to view'))
                          : _ConciergeThreadDetail(userId: _selectedUserId!),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConciergeThreadDetail extends ConsumerStatefulWidget {
  final String userId;

  const _ConciergeThreadDetail({required this.userId});

  @override
  ConsumerState<_ConciergeThreadDetail> createState() => _ConciergeThreadDetailState();
}

class _ConciergeThreadDetailState extends ConsumerState<_ConciergeThreadDetail> {
  final _controller = TextEditingController();
  bool _isSending = false;

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() => _isSending = true);
    try {
      await ref.read(conciergeApiProvider).replyToThread(widget.userId, text);
      _controller.clear();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(conciergeMessagesStreamProvider(widget.userId));
    final theme = Theme.of(context);

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: theme.colorScheme.surfaceContainerHighest,
          width: double.infinity,
          child: Text(
            'Chat with User ${widget.userId.substring(0, 8)}...',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: messagesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Error: $err')),
            data: (messages) {
              if (messages.isEmpty) return const Center(child: Text('No messages.'));
              return ListView.builder(
                reverse: true, // Assuming orderby desc means latest is first
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final msg = messages[index];
                  final isConcierge = msg.senderType != 'user';
                  return Align(
                    alignment: isConcierge ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isConcierge ? theme.colorScheme.primaryContainer : theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(msg.text),
                    ),
                  );
                },
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    hintText: 'Type a reply...',
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: _isSending ? null : _sendMessage,
                icon: _isSending
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.send),
                color: theme.colorScheme.primary,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
