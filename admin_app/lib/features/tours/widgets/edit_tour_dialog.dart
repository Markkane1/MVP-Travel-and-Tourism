import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/tour.dart';
import '../providers/tours_providers.dart';

class EditTourDialog extends ConsumerStatefulWidget {
  final Tour tour;
  const EditTourDialog({super.key, required this.tour});

  @override
  ConsumerState<EditTourDialog> createState() => _EditTourDialogState();
}

class _EditTourDialogState extends ConsumerState<EditTourDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _destinationController;
  late final TextEditingController _priceController;
  late final TextEditingController _durationController;
  late final TextEditingController _heroUrlController;
  late final TextEditingController _galleryUrlsController;
  late final TextEditingController _badgesController;
  late final TextEditingController _maxParticipantsController;
  late final TextEditingController _ratingAvgController;
  late final TextEditingController _ratingCountController;
  late final TextEditingController _overviewController;
  late final TextEditingController _inclusionsController;
  late final TextEditingController _privateVehicleSurchargeController;
  late final TextEditingController _itineraryJsonController;
  late final TextEditingController _groupSizeJsonController;

  late String _selectedCategory;
  final List<String> _categories = ['Safari', 'Beach', 'Mountain', 'City', 'Cultural'];

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.tour.title);
    _destinationController = TextEditingController(text: widget.tour.destination);
    _priceController = TextEditingController(text: widget.tour.pricePerPerson.toString());
    _durationController = TextEditingController(text: widget.tour.durationDays.toString());
    _heroUrlController = TextEditingController(text: widget.tour.heroImageUrl);
    _galleryUrlsController = TextEditingController(text: widget.tour.galleryImageUrls.join(', '));
    _badgesController = TextEditingController(text: widget.tour.badges.join(', '));
    _maxParticipantsController = TextEditingController(text: widget.tour.maxParticipants.toString());
    _ratingAvgController = TextEditingController(text: widget.tour.ratingAverage.toString());
    _ratingCountController = TextEditingController(text: widget.tour.ratingCount.toString());
    _overviewController = TextEditingController(text: widget.tour.overview);
    _inclusionsController = TextEditingController(text: widget.tour.inclusions.join(', '));
    _privateVehicleSurchargeController = TextEditingController(text: widget.tour.privateVehicleSurcharge.toString());
    
    _itineraryJsonController = TextEditingController(text: jsonEncode(widget.tour.itinerary));
    _groupSizeJsonController = TextEditingController(text: jsonEncode(widget.tour.groupSizeOptions));

    _selectedCategory = _categories.contains(widget.tour.category) ? widget.tour.category : _categories.first;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _destinationController.dispose();
    _priceController.dispose();
    _durationController.dispose();
    _heroUrlController.dispose();
    _galleryUrlsController.dispose();
    _badgesController.dispose();
    _maxParticipantsController.dispose();
    _ratingAvgController.dispose();
    _ratingCountController.dispose();
    _overviewController.dispose();
    _inclusionsController.dispose();
    _privateVehicleSurchargeController.dispose();
    _itineraryJsonController.dispose();
    _groupSizeJsonController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      List<Map<String, dynamic>> itineraryParsed = [];
      List<Map<String, dynamic>> groupSizeParsed = [];
      try {
        final parsedI = jsonDecode(_itineraryJsonController.text);
        if (parsedI is List) itineraryParsed = List<Map<String, dynamic>>.from(parsedI);
        final parsedG = jsonDecode(_groupSizeJsonController.text);
        if (parsedG is List) groupSizeParsed = List<Map<String, dynamic>>.from(parsedG);
      } catch (_) {}

      final updatedTour = widget.tour.copyWith(
        title: _titleController.text.trim(),
        destination: _destinationController.text.trim(),
        category: _selectedCategory,
        pricePerPerson: double.tryParse(_priceController.text) ?? widget.tour.pricePerPerson,
        durationDays: int.tryParse(_durationController.text) ?? widget.tour.durationDays,
        heroImageUrl: _heroUrlController.text.trim(),
        galleryImageUrls: _galleryUrlsController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
        badges: _badgesController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
        inclusions: _inclusionsController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
        maxParticipants: int.tryParse(_maxParticipantsController.text) ?? widget.tour.maxParticipants,
        ratingAverage: double.tryParse(_ratingAvgController.text) ?? widget.tour.ratingAverage,
        ratingCount: int.tryParse(_ratingCountController.text) ?? widget.tour.ratingCount,
        overview: _overviewController.text.trim(),
        privateVehicleSurcharge: double.tryParse(_privateVehicleSurchargeController.text) ?? widget.tour.privateVehicleSurcharge,
        itinerary: itineraryParsed,
        groupSizeOptions: groupSizeParsed,
      );

      await ref.read(toursApiProvider).updateTour(updatedTour);
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: \$e')));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Tour'),
      content: SizedBox(
        width: 600,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Tour Title', border: OutlineInputBorder()),
                  validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _destinationController,
                        decoration: const InputDecoration(labelText: 'Destination', border: OutlineInputBorder()),
                        validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
                        items: _categories.map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedCategory = val);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _priceController,
                        decoration: const InputDecoration(labelText: 'Price per Person', prefixText: '\$ ', border: OutlineInputBorder()),
                        keyboardType: TextInputType.number,
                        validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _durationController,
                        decoration: const InputDecoration(labelText: 'Duration (Days)', suffixText: ' days', border: OutlineInputBorder()),
                        keyboardType: TextInputType.number,
                        validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _overviewController,
                  decoration: const InputDecoration(labelText: 'Overview', border: OutlineInputBorder()),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _heroUrlController,
                  decoration: const InputDecoration(labelText: 'Hero Image URL', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _galleryUrlsController,
                  decoration: const InputDecoration(labelText: 'Gallery Image URLs (comma separated)', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _badgesController,
                  decoration: const InputDecoration(labelText: 'Badges (comma separated)', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _inclusionsController,
                  decoration: const InputDecoration(labelText: 'Inclusions (comma separated)', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _maxParticipantsController,
                        decoration: const InputDecoration(labelText: 'Max Participants', border: OutlineInputBorder()),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _privateVehicleSurchargeController,
                        decoration: const InputDecoration(labelText: 'Private Vehicle Surcharge (\$)', border: OutlineInputBorder()),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _ratingAvgController,
                        decoration: const InputDecoration(labelText: 'Rating Average (0.0 - 5.0)', border: OutlineInputBorder()),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _ratingCountController,
                        decoration: const InputDecoration(labelText: 'Rating Count', border: OutlineInputBorder()),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _itineraryJsonController,
                  decoration: const InputDecoration(labelText: 'Itinerary JSON Array', border: OutlineInputBorder()),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _groupSizeJsonController,
                  decoration: const InputDecoration(labelText: 'Group Size Options JSON Array', border: OutlineInputBorder()),
                  maxLines: 3,
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
        FilledButton(
          onPressed: _isSubmitting ? null : _submitForm,
          child: _isSubmitting 
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Text('Save Changes'),
        ),
      ],
    );
  }
}
