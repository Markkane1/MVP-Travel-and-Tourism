import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../../../core/services/cloudinary_service.dart';
import '../models/tour.dart';
import '../providers/tours_providers.dart';

class AddTourDialog extends ConsumerStatefulWidget {
  const AddTourDialog({super.key});

  @override
  ConsumerState<AddTourDialog> createState() => _AddTourDialogState();
}

class _AddTourDialogState extends ConsumerState<AddTourDialog> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _destinationController = TextEditingController();
  final _priceController = TextEditingController();
  final _durationController = TextEditingController();
  final _heroUrlController = TextEditingController();
  final _galleryUrlsController = TextEditingController();
  final _badgesController = TextEditingController();
  final _maxParticipantsController = TextEditingController(text: '10');
  final _ratingAvgController = TextEditingController(text: '0.0');
  final _ratingCountController = TextEditingController(text: '0');
  final _overviewController = TextEditingController();
  final _inclusionsController = TextEditingController();
  final _privateVehicleSurchargeController = TextEditingController(text: '0.0');
  final _itineraryJsonController = TextEditingController(text: '[]');
  final _groupSizeJsonController = TextEditingController(text: '[]');

  String _selectedCategory = 'Safari';
  final List<String> _categories = ['Safari', 'Beach', 'Mountain', 'City', 'Cultural'];

  bool _isSubmitting = false;
  bool _isUploadingImage = false;
  final _cloudinaryService = CloudinaryService();

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

  Future<void> _pickAndUploadHeroImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;
    final file = result.files.first;
    if (file.bytes == null) return;

    setState(() => _isUploadingImage = true);
    try {
      final url = await _cloudinaryService.uploadImage(
        bytes: file.bytes!,
        folder: 'tours/heroes',
        fileName: file.name,
      );
      _heroUrlController.text = url;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploadingImage = false);
    }
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

      final newTour = Tour(
        title: _titleController.text.trim(),
        destination: _destinationController.text.trim(),
        category: _selectedCategory,
        pricePerPerson: double.tryParse(_priceController.text) ?? 0.0,
        durationDays: int.tryParse(_durationController.text) ?? 1,
        heroImageUrl: _heroUrlController.text.trim().isEmpty ? 'https://via.placeholder.com/800x600?text=Placeholder+Hero' : _heroUrlController.text.trim(),
        galleryImageUrls: _galleryUrlsController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
        badges: _badgesController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
        inclusions: _inclusionsController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
        maxParticipants: int.tryParse(_maxParticipantsController.text) ?? 10,
        ratingAverage: double.tryParse(_ratingAvgController.text) ?? 0.0,
        ratingCount: int.tryParse(_ratingCountController.text) ?? 0,
        overview: _overviewController.text.trim(),
        privateVehicleSurcharge: double.tryParse(_privateVehicleSurchargeController.text) ?? 0.0,
        itinerary: itineraryParsed,
        groupSizeOptions: groupSizeParsed,
      );

      await ref.read(toursApiProvider).addTour(newTour);
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
      title: const Text('Add New Tour'),
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
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _heroUrlController,
                        decoration: const InputDecoration(
                          labelText: 'Hero Image URL',
                          hintText: 'Paste a URL or upload a file →',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: _isUploadingImage ? null : _pickAndUploadHeroImage,
                        icon: _isUploadingImage
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.upload),
                        label: const Text('Upload'),
                      ),
                    ),
                  ],
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
              : const Text('Create Tour'),
        ),
      ],
    );
  }
}
