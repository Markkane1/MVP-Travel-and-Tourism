import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/bookings_providers.dart';
import '../models/booking.dart';

class AddBookingDialog extends ConsumerStatefulWidget {
  const AddBookingDialog({super.key});

  @override
  ConsumerState<AddBookingDialog> createState() => _AddBookingDialogState();
}

class _AddBookingDialogState extends ConsumerState<AddBookingDialog> {
  final _formKey = GlobalKey<FormState>();
  final _userIdController = TextEditingController();
  final _tourIdController = TextEditingController();
  final _pickupLocationController = TextEditingController();

  DateTime? _selectedDate;
  int _adults = 1;
  int _children = 0;
  bool _privateVehicle = false;
  double _totalPrice = 0.0;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _userIdController.dispose();
    _tourIdController.dispose();
    _pickupLocationController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
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
    if (_selectedDate == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a date')));
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final newBooking = Booking(
        id: '', // Generated in provider
        userId: _userIdController.text.trim(),
        tourId: _tourIdController.text.trim(),
        tourSnapshot: const {'title': 'Manual Booking', 'currency': 'USD'},
        date: _selectedDate!,
        adults: _adults,
        children: _children,
        totalPrice: _totalPrice,
        pickupLocation: _pickupLocationController.text.trim(),
        status: 'confirmed',
        privateVehicle: _privateVehicle,
      );

      await ref.read(bookingsApiProvider).addBooking(newBooking);
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
      title: const Text('Add Manual Booking'),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _userIdController,
                  decoration: const InputDecoration(
                    labelText: 'User ID',
                    border: OutlineInputBorder(),
                  ),
                  validator: (val) =>
                      val == null || val.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _tourIdController,
                  decoration: const InputDecoration(
                    labelText: 'Tour ID',
                    border: OutlineInputBorder(),
                  ),
                  validator: (val) =>
                      val == null || val.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                ListTile(
                  title: Text(
                    _selectedDate == null
                        ? 'Select Date'
                        : 'Date: ${_selectedDate!.toLocal().toString().split(' ')[0]}',
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
                  decoration: const InputDecoration(
                    labelText: 'Total Price (\$)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (val) => _totalPrice = double.tryParse(val) ?? 0.0,
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
              : const Text('Create Booking'),
        ),
      ],
    );
  }
}
