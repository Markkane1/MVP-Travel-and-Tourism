import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/bookings_providers.dart';
import '../models/booking.dart';

class EditBookingDialog extends ConsumerStatefulWidget {
  final Booking booking;
  const EditBookingDialog({super.key, required this.booking});

  @override
  ConsumerState<EditBookingDialog> createState() => _EditBookingDialogState();
}

class _EditBookingDialogState extends ConsumerState<EditBookingDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _pickupLocationController;
  late TextEditingController _totalPriceController;

  late DateTime _selectedDate;
  late int _adults;
  late int _children;
  late bool _privateVehicle;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _pickupLocationController = TextEditingController(
      text: widget.booking.pickupLocation,
    );
    _totalPriceController = TextEditingController(
      text: widget.booking.totalPrice.toString(),
    );
    _selectedDate = widget.booking.date ?? DateTime.now();
    _adults = widget.booking.adults;
    _children = widget.booking.children;
    _privateVehicle = widget.booking.privateVehicle;
  }

  @override
  void dispose() {
    _pickupLocationController.dispose();
    _totalPriceController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    try {
      final updates = {
        'date': _selectedDate.toIso8601String(),
        'adults': _adults,
        'children': _children,
        'pickupLocation': _pickupLocationController.text.trim(),
        'privateVehicle': _privateVehicle,
        'totalPrice':
            double.tryParse(_totalPriceController.text) ??
            widget.booking.totalPrice,
      };

      await ref
          .read(bookingsApiProvider)
          .updateBookingDetails(widget.booking.id, updates);
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
      title: Text('Edit Booking ${widget.booking.id.substring(0, 8)}'),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: Text(
                    'Date: ${_selectedDate.toLocal().toString().split(' ')[0]}',
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: _selectDate,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        initialValue: _adults,
                        decoration: const InputDecoration(
                          labelText: 'Adults',
                          border: OutlineInputBorder(),
                        ),
                        items: List.generate(
                          10,
                          (i) => DropdownMenuItem(
                            value: i + 1,
                            child: Text('${i + 1}'),
                          ),
                        ),
                        onChanged: (val) => setState(() => _adults = val ?? 1),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        initialValue: _children,
                        decoration: const InputDecoration(
                          labelText: 'Children',
                          border: OutlineInputBorder(),
                        ),
                        items: List.generate(
                          10,
                          (i) => DropdownMenuItem(value: i, child: Text('$i')),
                        ),
                        onChanged: (val) =>
                            setState(() => _children = val ?? 0),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _pickupLocationController,
                  decoration: const InputDecoration(
                    labelText: 'Pickup Location',
                    border: OutlineInputBorder(),
                  ),
                  validator: (val) =>
                      val == null || val.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  title: const Text('Private Vehicle'),
                  value: _privateVehicle,
                  onChanged: (val) => setState(() => _privateVehicle = val),
                  contentPadding: EdgeInsets.zero,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _totalPriceController,
                  decoration: const InputDecoration(
                    labelText: 'Total Price (\$)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (val) =>
                      val == null || val.isEmpty ? 'Required' : null,
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
              : const Text('Save Changes'),
        ),
      ],
    );
  }
}
