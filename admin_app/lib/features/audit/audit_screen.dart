import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'providers/audit_providers.dart';
import 'models/audit_model.dart';

class AuditScreen extends ConsumerWidget {
  const AuditScreen({super.key});

  void _showDetails(BuildContext context, AuditModel log) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Audit Log Details'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _DetailRow('Log ID', log.id),
                _DetailRow('Actor Email', log.actorEmail),
                _DetailRow('Actor Role', log.actorRole),
                _DetailRow('Action', log.action),
                _DetailRow('Target Type', log.targetType),
                _DetailRow('Target ID', log.targetId),
                _DetailRow('Summary', log.summary),
                if (log.reason != null && log.reason!.isNotEmpty)
                  _DetailRow('Reason', log.reason!),
                if (log.createdAt != null)
                  _DetailRow('Date', DateFormat.yMMMd().add_Hms().format(log.createdAt!)),
                const SizedBox(height: 16),
                if (log.before != null) ...[
                  const Text('Before:', style: TextStyle(fontWeight: FontWeight.bold)),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    color: Colors.grey[100],
                    child: Text(log.before.toString()),
                  ),
                  const SizedBox(height: 8),
                ],
                if (log.after != null) ...[
                  const Text('After:', style: TextStyle(fontWeight: FontWeight.bold)),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    color: Colors.grey[100],
                    child: Text(log.after.toString()),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auditLogsAsync = ref.watch(auditLogsProvider);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Security Audit Logs',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
                ),
                child: auditLogsAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => Center(child: Text('Error loading logs: \$err')),
                  data: (logs) {
                    if (logs.isEmpty) {
                      return const Center(child: Text('No audit logs available.'));
                    }
                    return ListView.separated(
                      itemCount: logs.length,
                      separatorBuilder: (context, index) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final log = logs[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: _getActionColor(log.action).withOpacity(0.1),
                            child: Icon(_getActionIcon(log.action), color: _getActionColor(log.action)),
                          ),
                          title: Text(log.summary, style: const TextStyle(fontWeight: FontWeight.w500)),
                          subtitle: Text('\${log.actorEmail} • \${log.createdAt != null ? DateFormat.yMMMd().add_jm().format(log.createdAt!) : ''}'),
                          trailing: IconButton(
                            icon: const Icon(Icons.chevron_right),
                            onPressed: () => _showDetails(context, log),
                          ),
                          onTap: () => _showDetails(context, log),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getActionColor(String action) {
    if (action.contains('Delete') || action.contains('deactivate')) return Colors.red;
    if (action.contains('Create')) return Colors.green;
    if (action.contains('Update') || action.contains('updateRole')) return Colors.blue;
    return Colors.grey;
  }

  IconData _getActionIcon(String action) {
    if (action.contains('Delete') || action.contains('deactivate')) return Icons.delete;
    if (action.contains('Create')) return Icons.add_circle;
    if (action.contains('Update') || action.contains('updateRole')) return Icons.edit;
    return Icons.info;
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
