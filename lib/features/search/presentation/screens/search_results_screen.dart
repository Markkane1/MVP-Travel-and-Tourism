import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../explore/domain/tour.dart';
import '../../data/search_repository.dart';
import '../../data/saved_tours_repository.dart';
import 'search_map_screen.dart';

/// Renders search results based on query parameters.
class SearchResultsScreen extends ConsumerStatefulWidget {
  final Map<String, String> queryParameters;

  const SearchResultsScreen({super.key, required this.queryParameters});

  @override
  ConsumerState<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends ConsumerState<SearchResultsScreen> {
  late SearchFilters _currentFilters;
  bool _isMapView = false;

  final List<String> _destinationsList = [
    'All Destinations',
    'Paris, France',
    'Serengeti, Tanzania',
    'Bora Bora, French Polynesia',
    'Fiji Islands',
    'Zanzibar, Tanzania',
    'Maldives',
    'Zermatt, Switzerland',
    'Kyoto, Japan'
  ];

  final List<String> _priceRangesList = [
    'Any Price',
    'Under \$1,000',
    '\$1,000–\$2,500',
    '\$2,500–\$5,000',
    '\$5,000+'
  ];

  @override
  void initState() {
    super.initState();
    _currentFilters = _parseFilters(widget.queryParameters);
  }

  SearchFilters _parseFilters(Map<String, String> params) {
    final query = params['query'];
    final category = params['category'];
    final destination = params['destination'];
    final priceRange = params['priceRange'];

    double? minPrice;
    double? maxPrice;

    if (priceRange != null) {
      if (priceRange == 'Under \$1,000') {
        maxPrice = 1000.0;
      } else if (priceRange == '\$1,000–\$2,500') {
        minPrice = 1000.0;
        maxPrice = 2500.0;
      } else if (priceRange == '\$2,500–\$5,000') {
        minPrice = 2500.0;
        maxPrice = 5000.0;
      } else if (priceRange == '\$5,000+') {
        minPrice = 5000.0;
      }
    }

    return SearchFilters(
      query: query,
      category: category ?? 'All',
      destination: destination ?? 'All Destinations',
      minPrice: minPrice,
      maxPrice: maxPrice,
    );
  }

  String _getPriceRangeLabel(SearchFilters filters) {
    if (filters.minPrice == null && filters.maxPrice == null) return 'Any Price';
    if (filters.minPrice == null && filters.maxPrice == 1000.0) return 'Under \$1,000';
    if (filters.minPrice == 1000.0 && filters.maxPrice == 2500.0) return '\$1,000–\$2,500';
    if (filters.minPrice == 2500.0 && filters.maxPrice == 5000.0) return '\$2,500–\$5,000';
    if (filters.minPrice == 5000.0) return '\$5,000+';
    return 'Custom Price';
  }

  void _showFiltersBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
      builder: (context) {
        String tempDest = _currentFilters.destination ?? 'All Destinations';
        String tempPrice = _getPriceRangeLabel(_currentFilters);

        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Adjust Filters',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  AppSpacing.gapMd,
                  // Destination list selector
                  DropdownButtonFormField<String>(
                    initialValue: tempDest,
                    decoration: const InputDecoration(labelText: 'Destination'),
                    items: _destinationsList
                        .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setModalState(() {
                          tempDest = val;
                        });
                      }
                    },
                  ),
                  AppSpacing.gapMd,
                  // Price list selector
                  DropdownButtonFormField<String>(
                    initialValue: tempPrice,
                    decoration: const InputDecoration(labelText: 'Price Range'),
                    items: _priceRangesList
                        .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setModalState(() {
                          tempPrice = val;
                        });
                      }
                    },
                  ),
                  AppSpacing.gapLg,
                  PrimaryButton(
                    label: 'Apply',
                    onPressed: () {
                      final updatedParams = <String, String>{};
                      if (_currentFilters.query != null) {
                        updatedParams['query'] = _currentFilters.query!;
                      }
                      if (_currentFilters.category != null) {
                        updatedParams['category'] = _currentFilters.category!;
                      }
                      updatedParams['destination'] = tempDest;
                      updatedParams['priceRange'] = tempPrice;

                      setState(() {
                        _currentFilters = _parseFilters(updatedParams);
                      });
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final results = ref.watch(searchResultsProvider(_currentFilters));
    final savedTours = ref.watch(optimisticSavedToursProvider).value ?? <String>{};

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
          onPressed: () => context.pop(),
        ),
        title: results.when(
          data: (tours) => Column(
            children: [
              Text(
                _currentFilters.destination == 'All Destinations'
                    ? 'Search Results'
                    : _currentFilters.destination ?? 'Search Results',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${tours.length} Results Found',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
          loading: () => Text('Searching...', style: theme.textTheme.titleMedium),
          error: (err, stack) => Text('Search failed', style: theme.textTheme.titleMedium),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: AppColors.onSurface),
            onPressed: () => context.pop(),
          ),
        ],
      ),
      body: results.when(
        data: (tours) {
          return Column(
            children: [
              // Removable filter chips row
              _buildFilterChipsRow(),

              // Content Area: List vs. Google Map View
              Expanded(
                child: _isMapView
                    ? SearchMapScreen(tours: tours)
                    : _buildToursList(tours, savedTours, theme),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Failed to load search results.'),
                AppSpacing.gapMd,
                ElevatedButton(
                  onPressed: () => ref.invalidate(searchResultsProvider(_currentFilters)),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
      // Floating Gold Map Switch Button
      floatingActionButton: results.maybeWhen(
        data: (tours) => FloatingActionButton(
          backgroundColor: AppColors.secondary,
          foregroundColor: AppColors.primary,
          child: Icon(_isMapView ? Icons.format_list_bulleted : Icons.map),
          onPressed: () {
            setState(() {
              _isMapView = !_isMapView;
            });
          },
        ),
        orElse: () => null,
      ),
    );
  }

  Widget _buildFilterChipsRow() {
    final chips = <Widget>[];

    // Category Filter Chip
    if (_currentFilters.category != null && _currentFilters.category != 'All') {
      chips.add(_buildRemovableChip(
        _currentFilters.category!,
        () => setState(() {
          _currentFilters = _currentFilters.copyWith(category: 'All');
        }),
      ));
    }

    // Destination Filter Chip
    if (_currentFilters.destination != null && _currentFilters.destination != 'All Destinations') {
      chips.add(_buildRemovableChip(
        _currentFilters.destination!,
        () => setState(() {
          _currentFilters = _currentFilters.copyWith(destination: 'All Destinations');
        }),
      ));
    }

    // Price Filter Chip
    final priceLabel = _getPriceRangeLabel(_currentFilters);
    if (priceLabel != 'Any Price') {
      chips.add(_buildRemovableChip(
        priceLabel,
        () => setState(() {
          _currentFilters = SearchFilters(
            query: _currentFilters.query,
            category: _currentFilters.category,
            destination: _currentFilters.destination,
            minPrice: null,
            maxPrice: null,
          );
        }),
      ));
    }

    // Keyword Query Chip
    if (_currentFilters.query != null && _currentFilters.query!.isNotEmpty) {
      chips.add(_buildRemovableChip(
        '"${_currentFilters.query}"',
        () => setState(() {
          _currentFilters = _currentFilters.copyWith(query: '');
        }),
      ));
    }

    return Container(
      height: 48.0,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        children: [
          Expanded(
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: chips,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.tune, color: AppColors.primary),
            onPressed: _showFiltersBottomSheet,
          ),
        ],
      ),
    );
  }

  Widget _buildRemovableChip(String label, VoidCallback onRemove) {
    return Padding(
      padding: const EdgeInsets.only(right: 6.0),
      child: Chip(
        label: Text(label),
        deleteIcon: const Icon(Icons.close, size: 14.0),
        onDeleted: onRemove,
        backgroundColor: AppColors.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
          side: const BorderSide(color: AppColors.outlineVariant),
        ),
      ),
    );
  }

  Widget _buildToursList(List<Tour> tours, Set<String> savedList, ThemeData theme) {
    if (tours.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off, size: 64.0, color: Colors.grey.shade400),
              AppSpacing.gapMd,
              Text(
                'No tours match these filters.',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4.0),
              Text(
                'Try adjusting your search.',
                style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.onSurfaceVariant),
              ),
              AppSpacing.gapLg,
              OutlinedButton(
                onPressed: () {
                  setState(() {
                    _currentFilters = const SearchFilters(
                      category: 'All',
                      destination: 'All Destinations',
                      query: '',
                    );
                  });
                },
                child: const Text('Clear Filters'),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: tours.length,
      itemBuilder: (context, index) {
        final tour = tours[index];
        final isSaved = savedList.contains(tour.id);

        return Container(
          margin: const EdgeInsets.only(bottom: 24.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.0),
            border: Border.all(color: AppColors.outlineVariant, width: 1.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Large image with Badges overlay
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(19.0)),
                    child: Image.network(
                      tour.heroImageUrl,
                      height: 180.0,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  // Left-badge: solid gold pill
                  if (tour.badges.isNotEmpty)
                    Positioned(
                      top: AppSpacing.md,
                      left: AppSpacing.md,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                        decoration: BoxDecoration(
                          color: AppColors.secondary,
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        child: Text(
                          tour.badges.first.toUpperCase(),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: AppColors.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  // Right-heart: translucent dark circle
                   Positioned(
                    top: AppSpacing.md,
                    right: AppSpacing.md,
                    child: CircleAvatar(
                      backgroundColor: Colors.black.withValues(alpha: 0.4),
                      radius: 20.0,
                      child: Semantics(
                        label: isSaved ? 'Remove from saved' : 'Save tour',
                        button: true,
                        child: IconButton(
                          tooltip: isSaved ? 'Remove from saved' : 'Save tour',
                          icon: Icon(
                            isSaved ? Icons.favorite : Icons.favorite_border,
                            color: isSaved ? Colors.red : Colors.white,
                            size: 20.0,
                          ),
                          onPressed: () async {
                            // Heart toggle updates state optimistically instantly
                            try {
                              await ref
                                  .read(optimisticSavedToursProvider.notifier)
                                  .toggleSave(tour.id);
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Failed to update bookmark: $e')),
                                );
                              }
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              // Body Content
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tour.title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6.0),
                    Text(
                      '${tour.durationDays} Days • Max ${tour.maxParticipants} people • ★ ${tour.rating}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    AppSpacing.gapMd,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'From',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                            Text(
                              '\$${tour.pricePerPerson.toInt()}',
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        ElevatedButton(
                          onPressed: () => context.push('/tour/${tour.id}'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('View Details'),
                              SizedBox(width: 4.0),
                              Icon(Icons.arrow_forward, size: 16.0),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
