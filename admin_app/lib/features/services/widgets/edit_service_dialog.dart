import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/service.dart';
import '../providers/services_providers.dart';

class EditServiceDialog extends ConsumerStatefulWidget {
  final Service service;

  const EditServiceDialog({super.key, required this.service});

  @override
  ConsumerState<EditServiceDialog> createState() => _EditServiceDialogState();
}

class _EditServiceDialogState extends ConsumerState<EditServiceDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _categoryController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _currencyController;
  late TextEditingController _sortOrderController;
  late TextEditingController _imageUrlController;
  
  late String _unitType;
  late bool _isActive;
  bool _isSubmitting = false;

  final List<String> _unitTypes = ['per_booking', 'per_person', 'flat', 'per_day'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.service.name);
    _categoryController = TextEditingController(text: widget.service.category);
    _descriptionController = TextEditingController(text: widget.service.description);
    _priceController = TextEditingController(text: widget.service.basePrice.toString());
    _currencyController = TextEditingController(text: widget.service.currency);
    _sortOrderController = TextEditingController(text: widget.service.sortOrder.toString());
    _imageUrlController = TextEditingController(text: widget.service.imageUrl ?? '');
    
    _unitType = widget.service.unitType;
    _isActive = widget.service.isActive;
  }

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

    final updatedService = widget.service.copyWith(
      name: _nameController.text.trim(),
      category: _categoryController.text.trim(),
      description: _descriptionController.text.trim(),
      basePrice: double.parse(_priceController.text.trim()),
      currency: _currencyController.text.trim(),
      unitType: _unitType,
      sortOrder: int.parse(_sortOrderController.text.trim()),
      imageUrl: _imageUrlController.text.trim().isEmpty ? null : _imageUrlController.text.trim(),
      isActive: _isActive,
    );

    try {
      await ref.read(servicesApiProvider).updateService(updatedService);
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating service: \$e')),
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
      title: const Text('Edit Service'),
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
              : const Text('Save Changes'),
        ),
      ],
    );
  }
}
