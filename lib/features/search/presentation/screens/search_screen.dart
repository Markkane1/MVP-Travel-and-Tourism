import 'package:flutter/material.dart';
import '../../../../core/theme/app_radii.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/route_paths.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../explore/explore.dart';

/// Default Search panel dashboard screen.
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';
  String _selectedDestination = 'All Destinations';
  String _selectedPriceRange = 'Any Price';

  final List<String> _categories = ['All', 'Beach', 'Mountain', 'City', 'Adventure', 'Wellness'];

  final List<String> _destinations = [
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

  final List<String> _priceRanges = [
    'Any Price',
    'Under \$1,000',
    '\$1,000–\$2,500',
    '\$2,500–\$5,000',
    '\$5,000+'
  ];

  void _showSelectorBottomSheet({
    required String title,
    required List<String> options,
    required String currentValue,
    required ValueChanged<String> onSelected,
  }) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.xl)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            AppSpacing.gapMd,
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final option = options[index];
                  final isSelected = option == currentValue;
                  return ListTile(
                    title: Text(
                      option,
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? AppColors.primary : AppColors.onSurface,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check, color: AppColors.primary)
                        : null,
                    onTap: () {
                      onSelected(option);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _applyFilters() {
    final queryParams = <String, String>{};

    if (_searchController.text.isNotEmpty) {
      queryParams['query'] = _searchController.text;
    }
    if (_selectedCategory != 'All') {
      queryParams['category'] = _selectedCategory;
    }
    if (_selectedDestination != 'All Destinations') {
      queryParams['destination'] = _selectedDestination;
    }
    if (_selectedPriceRange != 'Any Price') {
      queryParams['priceRange'] = _selectedPriceRange;
    }

    context.push(
      Uri(path: RoutePaths.searchResults, queryParameters: queryParams).toString(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final featured = ref.watch(featuredToursProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: const IconButton(
          icon: Icon(Icons.menu, color: AppColors.onSurface),
          onPressed: null,
        ),
        title: Text(
          'Search',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: AppSpacing.md),
            child: CircleAvatar(
              radius: 18.0,
              backgroundImage: NetworkImage(
                'https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=150',
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(
              left: AppSpacing.lg,
              right: AppSpacing.lg,
              top: AppSpacing.md,
              bottom: 96.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Search Bar Input
                TextField(
                  controller: _searchController,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => _applyFilters(),
                  decoration: InputDecoration(
                    hintText: 'Search tours, activities...',
                    prefixIcon: const Icon(Icons.search, color: AppColors.onSurfaceVariant),
                    fillColor: Colors.white,
                    filled: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14.0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide: const BorderSide(color: AppColors.outlineVariant, width: 1.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide: const BorderSide(color: AppColors.outlineVariant, width: 1.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                    ),
                  ),
                ),
                AppSpacing.gapLg,

                // 2. Categories chips Header & Row
                Text(
                  'Category',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                AppSpacing.gapMd,
                SizedBox(
                  height: 40.0,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final category = _categories[index];
                      final isSelected = _selectedCategory == category;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: Text(category),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _selectedCategory = category;
                              });
                              context.push('${RoutePaths.searchResults}?category=${Uri.encodeComponent(category)}');
                            }
                          },
                          backgroundColor: AppColors.surfaceContainerLow,
                          selectedColor: AppColors.primary,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : AppColors.onSurface,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                            side: BorderSide(
                              color: isSelected ? AppColors.primary : AppColors.outlineVariant,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                AppSpacing.gapLg,

                // 3. Side-by-side selectors
                Row(
                  children: [
                    // Destination Dropdown
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Destination',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: AppColors.onSurfaceVariant,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6.0),
                          GestureDetector(
                            onTap: () => _showSelectorBottomSheet(
                              title: 'Select Destination',
                              options: _destinations,
                              currentValue: _selectedDestination,
                              onSelected: (val) {
                                setState(() {
                                  _selectedDestination = val;
                                });
                              },
                            ),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12.0,
                                vertical: 12.0,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(color: AppColors.outlineVariant),
                                borderRadius: AppRadii.borderMd,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      _selectedDestination,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: theme.textTheme.bodyMedium,
                                    ),
                                  ),
                                  const Icon(
                                    Icons.keyboard_arrow_down,
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12.0),
                    // Price Range Dropdown
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Price Range',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: AppColors.onSurfaceVariant,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6.0),
                          GestureDetector(
                            onTap: () => _showSelectorBottomSheet(
                              title: 'Select Price Range',
                              options: _priceRanges,
                              currentValue: _selectedPriceRange,
                              onSelected: (val) {
                                setState(() {
                                  _selectedPriceRange = val;
                                });
                              },
                            ),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12.0,
                                vertical: 12.0,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(color: AppColors.outlineVariant),
                                borderRadius: AppRadii.borderMd,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      _selectedPriceRange,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: theme.textTheme.bodyMedium,
                                    ),
                                  ),
                                  const Icon(
                                    Icons.keyboard_arrow_down,
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                AppSpacing.gapLg,

                // 4. Popular Tours list segment
                Text(
                  'Popular Tours',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                AppSpacing.gapMd,
                featured.when(
                  data: (tourList) {
                    // Combine and filter for matching tours
                    final displayTours = tourList.where((t) =>
                        t.id == 'maldives-retreat' ||
                        t.id == 'swiss-alpine' ||
                        t.id == 'kyoto-walk').toList();

                    // Fallback to first 3 tours if they are not in the database yet
                    final tours = displayTours.isNotEmpty
                        ? displayTours
                        : tourList.take(3).toList();

                    if (tours.isEmpty) {
                      return const Center(child: Text('No popular tours found.'));
                    }

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: tours.length,
                      itemBuilder: (context, index) {
                        final tour = tours[index];
                        String badge = 'POPULAR';
                        IconData badgeIcon = Icons.star;
                        if (tour.id == 'swiss-alpine') {
                          badge = 'TRENDING';
                          badgeIcon = Icons.trending_up;
                        } else if (tour.id == 'kyoto-walk') {
                          badge = 'EXCLUSIVE';
                          badgeIcon = Icons.stars_sharp;
                        }

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: AppRadii.borderLg,
                            border: Border.all(color: AppColors.outlineVariant),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: AppSpacing.sm,
                            ),
                            leading: ClipRRect(
                              borderRadius: AppRadii.borderMd,
                              child: Image.network(
                                tour.heroImageUrl,
                                width: 56.0,
                                height: 56.0,
                                fit: BoxFit.cover,
                              ),
                            ),
                            title: Row(
                              children: [
                                Icon(badgeIcon, size: 12.0, color: AppColors.secondary),
                                const SizedBox(width: 4.0),
                                Text(
                                  badge,
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: AppColors.secondary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 2.0),
                                Text(
                                  tour.title,
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 2.0),
                                Text(
                                  '${tour.durationDays} Days • Premium experience',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                            trailing: const Icon(
                              Icons.chevron_right,
                              color: AppColors.onSurfaceVariant,
                            ),
                            onTap: () => context.push('/tour/${tour.id}'),
                          ),
                        );
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => const Center(child: Text('Failed to load popular tours.')),
                ),
              ],
            ),
          ),
          // 5. Sticky Pinned Bottom Apply Filters button
          Positioned(
            left: AppSpacing.lg,
            right: AppSpacing.lg,
            bottom: AppSpacing.lg,
            child: PrimaryButton(
              label: 'Apply Filters',
              onPressed: _applyFilters,
            ),
          ),
        ],
      ),
    );
  }
}
