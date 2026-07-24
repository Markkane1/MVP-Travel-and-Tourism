import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/staff_providers.dart';
import 'models/staff_model.dart';

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
                      initialValue: selectedRole,
                      decoration: const InputDecoration(
                        labelText: 'Role',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'admin', child: Text('Admin')),
                        DropdownMenuItem(
                          value: 'super_admin',
                          child: Text('Super Admin'),
                        ),
                        DropdownMenuItem(
                          value: 'concierge',
                          child: Text('Concierge'),
                        ),
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
                  onPressed: isSubmitting
                      ? null
                      : () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          setState(() => isSubmitting = true);
                          try {
                            await ref
                                .read(staffApiProvider)
                                .registerStaffProfile(
                                  email: emailController.text.trim(),
                                  password: passwordController.text,
                                  role: selectedRole,
                                );
                            if (context.mounted) Navigator.of(context).pop();
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error: $e')),
                              );
                            }
                          } finally {
                            setState(() => isSubmitting = false);
                          }
                        },
                  child: isSubmitting
                      ? const CircularProgressIndicator()
                      : const Text('Register'),
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
                initialValue: selectedRole,
                decoration: const InputDecoration(
                  labelText: 'Role',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'admin', child: Text('Admin')),
                  DropdownMenuItem(
                    value: 'super_admin',
                    child: Text('Super Admin'),
                  ),
                  DropdownMenuItem(
                    value: 'concierge',
                    child: Text('Concierge'),
                  ),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => selectedRole = val);
                },
              ),
              actions: [
                TextButton(
                  onPressed: isSubmitting
                      ? null
                      : () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          setState(() => isSubmitting = true);
                          try {
                            await ref
                                .read(staffApiProvider)
                                .updateRole(uid: uid, role: selectedRole);
                            if (context.mounted) Navigator.of(context).pop();
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error: $e')),
                              );
                            }
                          } finally {
                            setState(() => isSubmitting = false);
                          }
                        },
                  child: isSubmitting
                      ? const CircularProgressIndicator()
                      : const Text('Save'),
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
        content: const Text(
          'Are you sure you want to disable this staff member? This will immediately revoke their access.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.errorContainer,
            ),
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
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: \$e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final staffAsync = ref.watch(staffStreamProvider);
    final theme = Theme.of(context);

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Staff Management',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _showCreateStaffDialog,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Staff'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            staffAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: \$err')),
              data: (staff) {
                if (staff.isEmpty) {
                  return const Center(child: Text('No staff profiles found.'));
                }

                final source = _StaffDataSource(
                  staff: staff,
                  context: context,
                  onUpdateRole: _updateRole,
                  onDeactivate: _deactivateStaff,
                );
                return SizedBox(
                  width: double.infinity,
                  child: Theme(
                    data: theme.copyWith(
                      cardTheme: const CardThemeData(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(16)),
                        ),
                        clipBehavior: Clip.antiAlias,
                      ),
                    ),
                    child: PaginatedDataTable(
                      source: source,
                      header: const Text(
                        'Staff Directory',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                        ),
                      ),
                      rowsPerPage: staff.length > 10 ? 10 : staff.length,
                      columns: const [
                        DataColumn(label: Text('Email')),
                        DataColumn(label: Text('Role')),
                        DataColumn(label: Text('Status')),
                        DataColumn(label: Text('Actions')),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _StaffDataSource extends DataTableSource {
  final List<StaffModel> staff;
  final BuildContext context;
  final Function(String, String) onUpdateRole;
  final Function(String) onDeactivate;

  _StaffDataSource({
    required this.staff,
    required this.context,
    required this.onUpdateRole,
    required this.onDeactivate,
  });

  @override
  DataRow? getRow(int index) {
    if (index >= staff.length) return null;
    final s = staff[index];
    final theme = Theme.of(context);

    return DataRow(
      cells: [
        DataCell(Text(s.email)),
        DataCell(
          Chip(
            label: Text(s.role.toUpperCase()),
            backgroundColor: s.role == 'super_admin'
                ? Colors.red.withValues(alpha: 0.1)
                : s.role == 'concierge'
                ? Colors.green.withValues(alpha: 0.1)
                : Colors.blue.withValues(alpha: 0.1),
          ),
        ),
        DataCell(
          Icon(
            s.isActive ? Icons.check_circle : Icons.cancel,
            color: s.isActive ? Colors.green : Colors.grey,
          ),
        ),
        DataCell(
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => onUpdateRole(s.id, s.role),
                tooltip: 'Edit Role',
              ),
              if (s.isActive)
                IconButton(
                  icon: const Icon(Icons.block),
                  color: theme.colorScheme.error,
                  onPressed: () => onDeactivate(s.id),
                  tooltip: 'Deactivate',
                ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => staff.length;

  @override
  int get selectedRowCount => 0;
}
