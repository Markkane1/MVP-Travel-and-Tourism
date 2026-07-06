import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/service.dart';
import '../providers/services_providers.dart';

class AddServiceDialog extends ConsumerStatefulWidget {
  const AddServiceDialog({super.key});

  @override
  ConsumerState<AddServiceDialog> createState() => _AddServiceDialogState();
}

class _AddServiceDialogState extends ConsumerState<AddServiceDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _categoryController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _currencyController = TextEditingController(text: 'USD');
  final _sortOrderController = TextEditingController(text: '0');
  final _imageUrlController = TextEditingController();
  
  String _unitType = 'per_booking';
  bool _isActive = true;
  bool _isSubmitting = false;

  final List<String> _unitTypes = ['per_booking', 'per_person', 'flat', 'per_day'];

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _currencyController.dispose();
    _sortOrderController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    final newService = Service(
      name: _nameController.text.trim(),
      category: _categoryController.text.trim(),
      description: _descriptionController.text.trim(),
      basePrice: double.parse(_priceController.text.trim()),
      currency: _currencyController.text.trim(),
      unitType: _unitType,
      imageUrl: _imageUrlController.text.trim().isEmpty ? null : _imageUrlController.text.trim(),
      sortOrder: int.parse(_sortOrderController.text.trim()),
      isActive: _isActive,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    try {
      await ref.read(servicesApiProvider).addService(newService);
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding service: \$e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Service'),
      content: SizedBox(
        width: 600,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                  validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _categoryController,
                  decoration: const InputDecoration(labelText: 'Category (e.g. Transport, Spa)'),
                  validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 3,
                  validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _imageUrlController,
                  decoration: const InputDecoration(labelText: 'Image URL (optional)'),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: _priceController,
                        decoration: const InputDecoration(labelText: 'Base Price'),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Required';
                          if (double.tryParse(value) == null) return 'Must be a number';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 1,
                      child: TextFormField(
                        controller: _currencyController,
                        decoration: const InputDecoration(labelText: 'Currency'),
                        validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _unitType,
                  decoration: const InputDecoration(labelText: 'Unit Type'),
                  items: _unitTypes.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(type),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _unitType = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _sortOrderController,
                        decoration: const InputDecoration(labelText: 'Sort Order (lower is first)'),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Required';
                          if (int.tryParse(value) == null) return 'Must be an integer';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: SwitchListTile(
                        title: const Text('Is Active'),
                        value: _isActive,
                        onChanged: (val) {
                          setState(() {
                            _isActive = val;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _submit,
          child: _isSubmitting
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Add Service'),
        ),
      ],
    );
  }
}
