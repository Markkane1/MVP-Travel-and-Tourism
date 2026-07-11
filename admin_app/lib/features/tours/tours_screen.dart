import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'models/tour.dart';
import 'providers/tours_providers.dart';
import 'widgets/add_tour_dialog.dart';
import 'widgets/edit_tour_dialog.dart';

class ToursScreen extends ConsumerStatefulWidget {
  const ToursScreen({super.key});

  @override
  ConsumerState<ToursScreen> createState() => _ToursScreenState();
}

class _ToursScreenState extends ConsumerState<ToursScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'All';
  String _selectedStatus = 'All';
  bool _isGridView = true;

  final List<String> _categories = ['All', 'Safari', 'Beach', 'Mountain', 'City', 'Cultural', 'Misc'];
  final List<String> _statuses = ['All', 'Active', 'Archived'];

  void _showAddTourDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AddTourDialog(),
    );
  }

  void _showEditTourDialog(BuildContext context, Tour tour) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => EditTourDialog(tour: tour),
    );
  }

  void _confirmArchive(BuildContext context, WidgetRef ref, Tour tour) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Archive Tour'),
        content: const Text('Are you sure you want to archive this tour? It will no longer appear on the traveler app.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              try {
                await ref.read(toursApiProvider).deleteTour(tour.id);
                if (context.mounted) Navigator.of(context).pop();
              } catch (e) {
                if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error, foregroundColor: Theme.of(context).colorScheme.onError),
            child: const Text('Archive'),
          ),
        ],
      ),
    );
  }

  Widget _buildToolbar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Search Bar
          Expanded(
            child: TextField(
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                hintText: 'Search tours...',
                prefixIcon: Icon(Icons.search, color: Theme.of(context).colorScheme.onSurfaceVariant),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
          const SizedBox(width: 16),
          
          // Category Filter
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedCategory,
                items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (val) => setState(() => _selectedCategory = val ?? 'All'),
                icon: Icon(Icons.keyboard_arrow_down, color: Theme.of(context).colorScheme.onSurfaceVariant),
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 14),
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Status Filter
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedStatus,
                items: _statuses.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (val) => setState(() => _selectedStatus = val ?? 'All'),
                icon: Icon(Icons.keyboard_arrow_down, color: Theme.of(context).colorScheme.onSurfaceVariant),
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 14),
              ),
            ),
          ),

          const Spacer(),

          // View Toggle
          SegmentedButton<bool>(
            segments: const [
              ButtonSegment(value: true, icon: Icon(Icons.grid_view_rounded), label: Text('Grid')),
              ButtonSegment(value: false, icon: Icon(Icons.view_list_rounded), label: Text('List')),
            ],
            selected: {_isGridView},
            onSelectionChanged: (set) => setState(() => _isGridView = set.first),
            style: SegmentedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.surface,
              selectedBackgroundColor: Theme.of(context).colorScheme.primary,
              selectedForegroundColor: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridView(List<Tour> tours) {
    return Scrollbar(
      thumbVisibility: true,
      child: GridView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 400,
          mainAxisSpacing: 24,
          crossAxisSpacing: 24,
          childAspectRatio: 0.85,
        ),
        itemCount: tours.length,
        itemBuilder: (context, index) {
          return PremiumTourCard(
            tour: tours[index],
            onEdit: () => _showEditTourDialog(context, tours[index]),
            onArchive: () => _confirmArchive(context, ref, tours[index]),
          );
        },
      ),
    );
  }

  Widget _buildListView(List<Tour> tours) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Theme.of(context).colorScheme.surfaceContainerHighest),
      ),
      clipBehavior: Clip.antiAlias,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: constraints.maxWidth),
                child: DataTable(
                  headingRowColor: WidgetStateProperty.all(Theme.of(context).colorScheme.surface),
            dataRowMaxHeight: 80,
            dataRowMinHeight: 80,
            columns: [
              DataColumn(label: Text('Tour', style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurfaceVariant))),
              DataColumn(label: Text('Category', style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurfaceVariant))),
              DataColumn(label: Text('Price', style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurfaceVariant))),
              DataColumn(label: Text('Duration', style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurfaceVariant))),
              DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurfaceVariant))),
              DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurfaceVariant))),
            ],
            rows: tours.map((tour) {
              final hasImage = tour.heroImageUrl.isNotEmpty && tour.heroImageUrl.startsWith('http');
              return DataRow(
                cells: [
                  DataCell(
                    Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: hasImage
                              ? Image.network(tour.heroImageUrl, width: 60, height: 60, fit: BoxFit.cover)
                              : Container(width: 60, height: 60, color: Theme.of(context).colorScheme.surfaceContainerHighest, child: Icon(Icons.image, color: Theme.of(context).colorScheme.outline)),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              tour.title.isEmpty ? 'Untitled' : tour.title,
                              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: Theme.of(context).colorScheme.onSurface),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.location_on, size: 14, color: Theme.of(context).colorScheme.onSurfaceVariant),
                                const SizedBox(width: 4),
                                Text(
                                  tour.destination.isEmpty ? 'Unknown' : tour.destination,
                                  style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 13),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  DataCell(
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(tour.category.isEmpty ? 'Misc' : tour.category, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontWeight: FontWeight.w500)),
                    )
                  ),
                  DataCell(Text('\$${tour.pricePerPerson.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w600))),
                  DataCell(Text('${tour.durationDays} Days')),
                  DataCell(
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: tour.isActive ? Colors.green.withValues(alpha: 0.1) : Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        tour.isActive ? 'Active' : 'Archived',
                        style: TextStyle(
                          color: tour.isActive ? Colors.green.shade700 : Theme.of(context).colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  ),
                  DataCell(
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit_outlined, color: Theme.of(context).colorScheme.onSurface),
                          onPressed: () => _showEditTourDialog(context, tour),
                          tooltip: 'Edit',
                        ),
                        if (tour.isActive)
                          IconButton(
                            icon: Icon(Icons.archive_outlined, color: Theme.of(context).colorScheme.error),
                            onPressed: () => _confirmArchive(context, ref, tour),
                            tooltip: 'Archive',
                          ),
                      ],
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  },
),
    );
  }

  @override
  Widget build(BuildContext context) {
    final toursAsync = ref.watch(toursStreamProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tours Management',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Manage and curate premium travel experiences',
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 16),
                    ),
                  ],
                ),
                FilledButton.icon(
                  onPressed: () => _showAddTourDialog(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Add New Tour'),
                  style: FilledButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.onSurface,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            _buildToolbar(),
            const SizedBox(height: 24),
            Expanded(
              child: toursAsync.when(
                data: (tours) {
                  // Apply Filters & Search
                  final filteredTours = tours.where((tour) {
                    // Search Filter
                    final q = _searchQuery.toLowerCase();
                    final matchesSearch = tour.title.toLowerCase().contains(q) || tour.destination.toLowerCase().contains(q);
                    if (!matchesSearch) return false;

                    // Category Filter
                    if (_selectedCategory != 'All' && tour.category != _selectedCategory) {
                      // fallback for empty category 
                      if (_selectedCategory == 'Misc' && tour.category.isEmpty) {
                        // match
                      } else {
                        return false;
                      }
                    }

                    // Status Filter
                    if (_selectedStatus == 'Active' && !tour.isActive) return false;
                    if (_selectedStatus == 'Archived' && tour.isActive) return false;

                    return true;
                  }).toList();

                  if (filteredTours.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off, size: 64, color: Theme.of(context).colorScheme.outline),
                          const SizedBox(height: 16),
                          Text('No tours found matching your criteria.', style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.outline)),
                        ],
                      ),
                    );
                  }

                  return _isGridView ? _buildGridView(filteredTours) : _buildListView(filteredTours);
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(
                  child: Text('Error loading tours:\n$err', style: TextStyle(color: Theme.of(context).colorScheme.error)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PremiumTourCard extends ConsumerStatefulWidget {
  final Tour tour;
  final VoidCallback onEdit;
  final VoidCallback onArchive;
  
  const PremiumTourCard({super.key, required this.tour, required this.onEdit, required this.onArchive});

  @override
  ConsumerState<PremiumTourCard> createState() => _PremiumTourCardState();
}

class _PremiumTourCardState extends ConsumerState<PremiumTourCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final hasImage = widget.tour.heroImageUrl.isNotEmpty && widget.tour.heroImageUrl.startsWith('http');
    final title = widget.tour.title.isEmpty ? 'Untitled Tour' : widget.tour.title;
    final destination = widget.tour.destination.isEmpty ? 'Unknown Destination' : widget.tour.destination;
    
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedScale(
        scale: _isHovered ? 1.02 : 1.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: _isHovered ? Colors.black.withValues(alpha: 0.12) : Colors.black.withValues(alpha: 0.04),
                blurRadius: _isHovered ? 24 : 10,
                offset: _isHovered ? const Offset(0, 12) : const Offset(0, 4),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image Section
              Expanded(
                flex: 5,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Image
                    if (hasImage)
                      Image.network(widget.tour.heroImageUrl, fit: BoxFit.cover)
                    else
                      Container(
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        child: Icon(Icons.image, size: 64, color: Theme.of(context).colorScheme.outline),
                      ),
                    
                    // Gradient Overlay
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.4),
                            Colors.transparent,
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.8),
                          ],
                          stops: const [0.0, 0.2, 0.6, 1.0],
                        ),
                      ),
                    ),

                    // Top Left: Status Badge
                    Positioned(
                      top: 16,
                      left: 16,
                      child: _GlassBadge(
                        text: widget.tour.isActive ? 'Active' : 'Archived',
                        color: widget.tour.isActive ? Colors.greenAccent : Theme.of(context).colorScheme.outline,
                      ),
                    ),

                    // Top Right: Category Badge
                    Positioned(
                      top: 16,
                      right: 16,
                      child: _GlassBadge(
                        text: widget.tour.category.isEmpty ? 'Misc' : widget.tour.category,
                        color: Colors.white,
                      ),
                    ),

                    // Bottom: Price & Duration
                    Positioned(
                      bottom: 16,
                      left: 16,
                      right: 16,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${widget.tour.currency} ${widget.tour.pricePerPerson.toStringAsFixed(2)}',
                            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          Row(
                            children: [
                              const Icon(Icons.schedule, color: Colors.white70, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                '${widget.tour.durationDays} Days',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Details Section
              Expanded(
                flex: 4,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.onSurface, height: 1.2),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              destination,
                              style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 14),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      // Actions Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (widget.tour.isActive)
                            IconButton(
                              icon: Icon(Icons.archive_outlined, color: Theme.of(context).colorScheme.error),
                              tooltip: 'Archive Tour',
                              onPressed: widget.onArchive,
                            ),
                          const SizedBox(width: 8),
                          FilledButton.icon(
                            onPressed: widget.onEdit,
                            icon: const Icon(Icons.edit, size: 16),
                            label: const Text('Edit'),
                            style: FilledButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                              foregroundColor: Theme.of(context).colorScheme.onSurface,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GlassBadge extends StatelessWidget {
  final String text;
  final Color color;

  const _GlassBadge({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          color: Colors.black.withValues(alpha: 0.3),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 6),
              Text(
                text,
                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
