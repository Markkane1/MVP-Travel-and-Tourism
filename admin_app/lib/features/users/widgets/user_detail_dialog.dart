import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  late TextEditingController _displayNameController;
  late TextEditingController _phoneNumberController;
  late String _selectedTier;

  @override
  void initState() {
    super.initState();
    _loyaltyPointsController = TextEditingController(text: widget.user.loyaltyPoints.toString());
    _conciergeIdController = TextEditingController(text: widget.user.conciergeId ?? '');
    _displayNameController = TextEditingController(text: widget.user.displayName ?? '');
    _phoneNumberController = TextEditingController(text: '');
    
    // Normalize tier string to avoid DropdownButton crashes
    String t = widget.user.tier.toLowerCase();
    if (t == 'standard') t = 'base';
    if (!['base', 'gold', 'platinum'].contains(t)) {
      t = 'base';
    }
    _selectedTier = t;
  }

  @override
  void dispose() {
    _loyaltyPointsController.dispose();
    _conciergeIdController.dispose();
    _displayNameController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    setState(() => _isLoading = true);
    try {
      final points = int.tryParse(_loyaltyPointsController.text) ?? widget.user.loyaltyPoints;
      final cId = _conciergeIdController.text.trim();
      final displayName = _displayNameController.text.trim();
      final phoneNumber = _phoneNumberController.text.trim();

      await ref.read(usersApiProvider).updateUser(
        widget.user.id,
        displayName: displayName.isEmpty ? null : displayName,
        phoneNumber: phoneNumber.isEmpty ? null : phoneNumber,
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

  Future<void> _deleteUser() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete User'),
        content: const Text('Are you sure you want to permanently delete this user and all their data? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);
    try {
      await ref.read(usersApiProvider).deleteUser(widget.user.id);
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final u = widget.user;

    return AlertDialog(
      title: Text('User ${u.id.substring(0, 8)}...'),
      content: SizedBox(
        width: 400,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Email: ${u.email}'),
              if (u.createdAt != null) Text('Joined: ${u.createdAt}'),
              const SizedBox(height: 16),
              
              const Text('User Insights', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              if (u.preferences != null && u.preferences!.isNotEmpty)
                Text('Preferences: ${u.preferences.toString()}'),
              if (u.preferences == null || u.preferences!.isEmpty)
                const Text('Preferences: None stated'),
              
              const SizedBox(height: 8),
              Text('Saved Tours: ${u.savedTours.length} tours saved'),
              if (u.savedTours.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, top: 4.0),
                  child: Text(u.savedTours.join(', '), style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.outline)),
                ),
              
              const Text('Bookings Summary:', style: TextStyle(fontWeight: FontWeight.bold)),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('bookings').where('userId', isEqualTo: u.id).snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                    );
                  }
                  if (snapshot.hasError) {
                    return Text('Error loading bookings', style: TextStyle(color: Theme.of(context).colorScheme.error));
                  }
                  final docs = snapshot.data?.docs ?? [];
                  if (docs.isEmpty) return const Text('No bookings found.');
                  final activeCount = docs.where((d) => (d.data() as Map<String, dynamic>)['status'] == 'confirmed').length;
                  return Text('${docs.length} total booking(s), $activeCount active/confirmed');
                },
              ),
              
              const Divider(height: 32),
              
              const Text('Update User Details', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              TextField(
                controller: _displayNameController,
                decoration: const InputDecoration(labelText: 'Display Name', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _phoneNumberController,
                decoration: const InputDecoration(labelText: 'Phone Number', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _selectedTier,
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
          onPressed: _isLoading ? null : _deleteUser,
          style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
          child: const Text('Delete User'),
        ),
        const Spacer(),
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _saveChanges,
          child: _isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Save Changes'),
        ),
      ],
    );
  }
}
