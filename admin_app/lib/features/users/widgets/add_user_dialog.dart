import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/users_providers.dart';

class AddUserDialog extends ConsumerStatefulWidget {
  const AddUserDialog({super.key});

  @override
  ConsumerState<AddUserDialog> createState() => _AddUserDialogState();
}

class _AddUserDialogState extends ConsumerState<AddUserDialog> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  String _selectedTier = 'base';
  bool _isSubmitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    try {
      await ref
          .read(usersApiProvider)
          .addUser(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
            displayName: _nameController.text.trim(),
            tier: _selectedTier,
          );
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New User'),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Manually register a user account from the admin dashboard.',
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email Address',
                    border: OutlineInputBorder(),
                  ),
                  validator: (val) =>
                      val == null || val.isEmpty || !val.contains('@')
                      ? 'Enter a valid email'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Temporary Password',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  validator: (val) => val == null || val.length < 6
                      ? 'Password must be at least 6 characters'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Display Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (val) =>
                      val == null || val.isEmpty ? 'Name is required' : null,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _selectedTier,
                  decoration: const InputDecoration(
                    labelText: 'Initial Tier',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'base',
                      child: Text('Base (Standard)'),
                    ),
                    DropdownMenuItem(value: 'gold', child: Text('Gold')),
                    DropdownMenuItem(
                      value: 'platinum',
                      child: Text('Platinum'),
                    ),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedTier = val);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _submit,
          child: _isSubmitting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Create User'),
        ),
      ],
    );
  }
}
