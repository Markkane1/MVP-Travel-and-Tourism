import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../../../core/services/cloudinary_service.dart';
import '../models/tour.dart';
import '../providers/tours_providers.dart';

class _ItineraryItem {
  final TextEditingController dayController = TextEditingController();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descController = TextEditingController();

  void dispose() {
    dayController.dispose();
    titleController.dispose();
    descController.dispose();
  }
}

class _GroupSizeItem {
  final TextEditingController sizeController = TextEditingController();
  final TextEditingController priceController = TextEditingController();

  void dispose() {
    sizeController.dispose();
    priceController.dispose();
  }
}

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
  final _maxParticipantsController = TextEditingController(text: '10');
  final _ratingAvgController = TextEditingController(text: '0.0');
  final _ratingCountController = TextEditingController(text: '0');
  final _overviewController = TextEditingController();
  final _privateVehicleSurchargeController = TextEditingController(text: '0.0');

  // Dynamic Lists
  final List<TextEditingController> _galleryControllers = [];
  final List<TextEditingController> _badgeControllers = [];
  final List<TextEditingController> _inclusionControllers = [];
  final List<_ItineraryItem> _itineraryItems = [];
  final List<_GroupSizeItem> _groupSizeItems = [];

  String _selectedCategory = 'Adventure';
  String _currency = 'USD';
  final List<String> _categories = ['Adventure', 'Cultural', 'Beach', 'City', 'Mountain'];
  final List<String> _currencies = ['USD', 'AED'];

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
    _maxParticipantsController.dispose();
    _ratingAvgController.dispose();
    _ratingCountController.dispose();
    _overviewController.dispose();
    _privateVehicleSurchargeController.dispose();

    for (var c in _galleryControllers) { c.dispose(); }
    for (var c in _badgeControllers) { c.dispose(); }
    for (var c in _inclusionControllers) { c.dispose(); }
    for (var item in _itineraryItems) { item.dispose(); }
    for (var item in _groupSizeItems) { item.dispose(); }

    super.dispose();
  }

  Future<void> _pickAndUploadHeroImage() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image, withData: true);
    if (result == null || result.files.isEmpty || result.files.first.bytes == null) return;

    setState(() => _isUploadingImage = true);
    try {
      final url = await _cloudinaryService.uploadImage(
        bytes: result.files.first.bytes!,
        folder: 'tours/heroes',
        fileName: result.files.first.name,
      );
      _heroUrlController.text = url;
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
    } finally {
      if (mounted) setState(() => _isUploadingImage = false);
    }
  }

  Future<void> _pickAndUploadGalleryImage(int index) async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image, withData: true);
    if (result == null || result.files.isEmpty || result.files.first.bytes == null) return;

    setState(() => _isUploadingImage = true);
    try {
      final url = await _cloudinaryService.uploadImage(
        bytes: result.files.first.bytes!,
        folder: 'tours/gallery',
        fileName: result.files.first.name,
      );
      _galleryControllers[index].text = url;
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
    } finally {
      if (mounted) setState(() => _isUploadingImage = false);
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    try {
      final newTour = Tour(
        title: _titleController.text.trim(),
        destination: _destinationController.text.trim(),
        category: _selectedCategory,
        pricePerPerson: double.tryParse(_priceController.text) ?? 0.0,
        currency: _currency,
        durationDays: int.tryParse(_durationController.text) ?? 1,
        heroImageUrl: _heroUrlController.text.trim(),
        maxParticipants: int.tryParse(_maxParticipantsController.text) ?? 10,
        ratingAverage: double.tryParse(_ratingAvgController.text) ?? 0.0,
        ratingCount: int.tryParse(_ratingCountController.text) ?? 0,
        overview: _overviewController.text.trim(),
        privateVehicleSurcharge: double.tryParse(_privateVehicleSurchargeController.text) ?? 0.0,
        
        galleryImageUrls: _galleryControllers.map((c) => c.text.trim()).where((s) => s.isNotEmpty).toList(),
        badges: _badgeControllers.map((c) => c.text.trim()).where((s) => s.isNotEmpty).toList(),
        inclusions: _inclusionControllers.map((c) => c.text.trim()).where((s) => s.isNotEmpty).toList(),
        
        itinerary: _itineraryItems.map((item) => {
          'day': int.tryParse(item.dayController.text) ?? 1,
          'title': item.titleController.text.trim(),
          'description': item.descController.text.trim(),
        }).where((m) => m['title'].toString().isNotEmpty).toList(),
        
        groupSizeOptions: _groupSizeItems.map((item) => {
          'size': int.tryParse(item.sizeController.text) ?? 1,
          'price': double.tryParse(item.priceController.text) ?? 0.0,
        }).where((m) => m['size'] != null).toList(),
      );

      await ref.read(toursApiProvider).addTour(newTour);
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Widget _buildSectionHeader(String title, String? subtitle) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(subtitle, style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant)),
          ],
          const Divider(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Tour'),
      content: SizedBox(
        width: 800,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader('Basic Details', 'Main information about the tour'),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(labelText: 'Tour Title', border: OutlineInputBorder()),
                        validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _selectedCategory,
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
                      flex: 2,
                      child: TextFormField(
                        controller: _destinationController,
                        decoration: const InputDecoration(labelText: 'Destination', border: OutlineInputBorder()),
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
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: _priceController,
                        decoration: const InputDecoration(labelText: 'Base Price per Person', border: OutlineInputBorder()),
                        keyboardType: TextInputType.number,
                        validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _currency,
                        decoration: const InputDecoration(labelText: 'Currency', border: OutlineInputBorder()),
                        items: _currencies.map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _currency = val);
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
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
                        decoration: const InputDecoration(labelText: 'Private Vehicle Surcharge', prefixText: '\$ ', border: OutlineInputBorder()),
                        keyboardType: TextInputType.number,
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

                _buildSectionHeader('Media', 'Upload high-quality images'),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _heroUrlController,
                        decoration: const InputDecoration(
                          labelText: 'Hero Image URL',
                          hintText: 'Main cover image',
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
                ..._galleryControllers.asMap().entries.map((entry) {
                  int idx = entry.key;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: entry.value,
                            decoration: InputDecoration(labelText: 'Gallery Image URL ${idx + 1}', border: const OutlineInputBorder()),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: Icon(Icons.upload_file, color: Theme.of(context).colorScheme.primary),
                          onPressed: _isUploadingImage ? null : () => _pickAndUploadGalleryImage(idx),
                          tooltip: 'Upload Image',
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Theme.of(context).colorScheme.error),
                          onPressed: () => setState(() {
                            _galleryControllers[idx].dispose();
                            _galleryControllers.removeAt(idx);
                          }),
                        ),
                      ],
                    ),
                  );
                }),
                TextButton.icon(
                  onPressed: () => setState(() => _galleryControllers.add(TextEditingController())),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Gallery Image'),
                ),

                _buildSectionHeader('Highlights & Inclusions', 'Tags and perks displayed on the tour card'),
                const Text('Badges (e.g., "Bestseller", "Family Friendly")'),
                const SizedBox(height: 8),
                ..._badgeControllers.asMap().entries.map((entry) {
                  int idx = entry.key;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: entry.value,
                            decoration: const InputDecoration(hintText: 'Badge name', border: OutlineInputBorder()),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Theme.of(context).colorScheme.error),
                          onPressed: () => setState(() {
                            _badgeControllers[idx].dispose();
                            _badgeControllers.removeAt(idx);
                          }),
                        ),
                      ],
                    ),
                  );
                }),
                TextButton.icon(
                  onPressed: () => setState(() => _badgeControllers.add(TextEditingController())),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Badge'),
                ),
                
                const SizedBox(height: 16),
                const Text('Inclusions (e.g., "Hotel Pickup", "Breakfast")'),
                const SizedBox(height: 8),
                ..._inclusionControllers.asMap().entries.map((entry) {
                  int idx = entry.key;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: entry.value,
                            decoration: const InputDecoration(hintText: 'Inclusion description', border: OutlineInputBorder()),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Theme.of(context).colorScheme.error),
                          onPressed: () => setState(() {
                            _inclusionControllers[idx].dispose();
                            _inclusionControllers.removeAt(idx);
                          }),
                        ),
                      ],
                    ),
                  );
                }),
                TextButton.icon(
                  onPressed: () => setState(() => _inclusionControllers.add(TextEditingController())),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Inclusion'),
                ),

                _buildSectionHeader('Itinerary', 'Day-by-day tour schedule'),
                ..._itineraryItems.asMap().entries.map((entry) {
                  int idx = entry.key;
                  final item = entry.value;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                flex: 1,
                                child: TextFormField(
                                  controller: item.dayController,
                                  decoration: const InputDecoration(labelText: 'Day', border: OutlineInputBorder()),
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                flex: 4,
                                child: TextFormField(
                                  controller: item.titleController,
                                  decoration: const InputDecoration(labelText: 'Title', hintText: 'e.g. Arrival in City', border: OutlineInputBorder()),
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Theme.of(context).colorScheme.error),
                                onPressed: () => setState(() {
                                  item.dispose();
                                  _itineraryItems.removeAt(idx);
                                }),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: item.descController,
                            decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
                            maxLines: 2,
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                TextButton.icon(
                  onPressed: () => setState(() {
                    final item = _ItineraryItem();
                    item.dayController.text = (_itineraryItems.length + 1).toString();
                    _itineraryItems.add(item);
                  }),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Itinerary Day'),
                ),

                _buildSectionHeader('Group Size Options', 'Pricing tiers based on group size'),
                ..._groupSizeItems.asMap().entries.map((entry) {
                  int idx = entry.key;
                  final item = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: item.sizeController,
                            decoration: const InputDecoration(labelText: 'Max Group Size', border: OutlineInputBorder()),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: item.priceController,
                            decoration: const InputDecoration(labelText: 'Price Per Person', prefixText: '\$ ', border: OutlineInputBorder()),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Theme.of(context).colorScheme.error),
                          onPressed: () => setState(() {
                            item.dispose();
                            _groupSizeItems.removeAt(idx);
                          }),
                        ),
                      ],
                    ),
                  );
                }),
                TextButton.icon(
                  onPressed: () => setState(() => _groupSizeItems.add(_GroupSizeItem())),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Group Size Option'),
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
