import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/staff_providers.dart';

class StaffScreen extends ConsumerStatefulWidget {
  const StaffScreen({super.key});

  @override
  ConsumerState<StaffScreen> createState() => _StaffScreenState();
}

class _StaffScreenState extends ConsumerState<StaffScreen> {
  Future<void> _showCreateStaffDialog() async {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    String selectedRole = 'admin';
    bool isSubmitting = false;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Register Staff Member'),
              content: SizedBox(
                width: 420,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Provide an email and strong password to register a new staff member.',
                      style: TextStyle(fontSize: 14, color: Colors.black87),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Temporary Password',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: selectedRole,
                      decoration: const InputDecoration(
                        labelText: 'Role',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'admin', child: Text('Admin')),
                        DropdownMenuItem(value: 'super_admin', child: Text('Super Admin')),
                        DropdownMenuItem(value: 'concierge', child: Text('Concierge')),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => selectedRole = val);
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSubmitting ? null : () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: isSubmitting ? null : () async {
                    setState(() => isSubmitting = true);
                    try {
                      await ref.read(staffApiProvider).registerStaffProfile(
                        email: emailController.text.trim(),
                        password: passwordController.text,
                        role: selectedRole,
                      );
                      if (context.mounted) Navigator.of(context).pop();
                    } catch (e) {
                      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                    } finally {
                      setState(() => isSubmitting = false);
                    }
                  },
                  child: isSubmitting ? const CircularProgressIndicator() : const Text('Register'),
                ),
              ],
            );
          },
        );
      },
    );
  }


  Future<void> _updateRole(String uid, String currentRole) async {
    String selectedRole = currentRole;
    bool isSubmitting = false;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Update Role'),
              content: DropdownButtonFormField<String>(
                value: selectedRole,
                decoration: const InputDecoration(labelText: 'Role', border: OutlineInputBorder()),
                items: const [
                  DropdownMenuItem(value: 'admin', child: Text('Admin')),
                  DropdownMenuItem(value: 'super_admin', child: Text('Super Admin')),
                  DropdownMenuItem(value: 'concierge', child: Text('Concierge')),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => selectedRole = val);
                },
              ),
              actions: [
                TextButton(
                  onPressed: isSubmitting ? null : () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: isSubmitting ? null : () async {
                    setState(() => isSubmitting = true);
                    try {
                      await ref.read(staffApiProvider).updateRole(uid: uid, role: selectedRole);
                      if (context.mounted) Navigator.of(context).pop();
                    } catch (e) {
                      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: \$e')));
                    } finally {
                      setState(() => isSubmitting = false);
                    }
                  },
                  child: isSubmitting ? const CircularProgressIndicator() : const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _deactivateStaff(String uid) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deactivation'),
        content: const Text('Are you sure you want to disable this staff member? This will immediately revoke their access.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.errorContainer),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Deactivate'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await ref.read(staffApiProvider).deactivate(uid: uid);
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: \$e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final staffAsync = ref.watch(staffStreamProvider);
    final theme = Theme.of(context);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Staff Management',
                  style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                ElevatedButton.icon(
                  onPressed: _showCreateStaffDialog,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Staff'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: theme.colorScheme.outlineVariant),
                ),
                child: staffAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => Center(child: Text('Error: \$err')),
                  data: (staff) {
                    if (staff.isEmpty) return const Center(child: Text('No staff profiles found.'));
                    
                    return SingleChildScrollView(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columns: const [
                            DataColumn(label: Text('Email')),
                            DataColumn(label: Text('Role')),
                            DataColumn(label: Text('Status')),
                            DataColumn(label: Text('Actions')),
                          ],
                          rows: staff.map((s) {
                            return DataRow(
                              cells: [
                                DataCell(Text(s.email)),
                                DataCell(
                                  Chip(
                                    label: Text(s.role.toUpperCase()),
                                    backgroundColor: s.role == 'super_admin' 
                                        ? Colors.red.withOpacity(0.1) 
                                        : s.role == 'concierge'
                                            ? Colors.green.withOpacity(0.1)
                                            : Colors.blue.withOpacity(0.1),
                                  ),
                                ),
                                DataCell(
                                  Icon(
                                    s.isActive ? Icons.check_circle : Icons.cancel,
                                    color: s.isActive ? Colors.green : Colors.grey,
                                  )
                                ),
                                DataCell(
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit),
                                        onPressed: () => _updateRole(s.id, s.role),
                                        tooltip: 'Edit Role',
                                      ),
                                      if (s.isActive)
                                        IconButton(
                                          icon: const Icon(Icons.block),
                                          color: theme.colorScheme.error,
                                          onPressed: () => _deactivateStaff(s.id),
                                          tooltip: 'Deactivate',
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
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
}
