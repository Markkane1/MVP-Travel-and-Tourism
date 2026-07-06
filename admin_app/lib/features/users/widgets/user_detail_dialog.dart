import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user.dart';
import '../providers/users_providers.dart';

class UserDetailDialog extends ConsumerStatefulWidget {
  final UserModel user;

  const UserDetailDialog({super.key, required this.user});

  @override
  ConsumerState<UserDetailDialog> createState() => _UserDetailDialogState();
}

class _UserDetailDialogState extends ConsumerState<UserDetailDialog> {
  bool _isLoading = false;
  late TextEditingController _loyaltyPointsController;
  late TextEditingController _conciergeIdController;
  late String _selectedTier;

  @override
  void initState() {
    super.initState();
    _loyaltyPointsController = TextEditingController(text: widget.user.loyaltyPoints.toString());
    _conciergeIdController = TextEditingController(text: widget.user.conciergeId ?? '');
    _selectedTier = widget.user.tier;
  }

  @override
  void dispose() {
    _loyaltyPointsController.dispose();
    _conciergeIdController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    setState(() => _isLoading = true);
    try {
      final points = int.tryParse(_loyaltyPointsController.text) ?? widget.user.loyaltyPoints;
      final cId = _conciergeIdController.text.trim();

      await ref.read(usersApiProvider).updateUser(
        widget.user.id,
        tier: _selectedTier,
        loyaltyPoints: points,
        conciergeId: cId.isEmpty ? '' : cId,
      );
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: \$e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final u = widget.user;

    return AlertDialog(
      title: Text('User \${u.id.substring(0, 8)}...'),
      content: SizedBox(
        width: 400,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Email: \${u.email}'),
              Text("Display Name: \${u.displayName ?? 'N/A'}"),
              if (u.createdAt != null) Text('Joined: \${u.createdAt}'),
              const Divider(),
              const Text('Update User Status', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedTier,
                decoration: const InputDecoration(labelText: 'Tier', border: OutlineInputBorder()),
                items: const [
                  DropdownMenuItem(value: 'base', child: Text('Base')),
                  DropdownMenuItem(value: 'gold', child: Text('Gold')),
                  DropdownMenuItem(value: 'platinum', child: Text('Platinum')),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _selectedTier = val);
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _loyaltyPointsController,
                decoration: const InputDecoration(labelText: 'Loyalty Points', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _conciergeIdController,
                decoration: const InputDecoration(labelText: 'Assigned Concierge ID (leave blank for unassigned)', border: OutlineInputBorder()),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _saveChanges,
          child: _isLoading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Save Changes'),
        ),
      ],
    );
  }
}
