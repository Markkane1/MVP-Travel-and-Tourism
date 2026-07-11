import 'package:flutter/material.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

/// Horizontal row of category cards matching the design export.
class CategorySelector extends StatefulWidget {
  final ValueChanged<String>? onCategorySelected;

  const CategorySelector({super.key, this.onCategorySelected});

  @override
  State<CategorySelector> createState() => _CategorySelectorState();
}

class _CategorySelectorState extends State<CategorySelector> {
  String _selectedCategory = 'Beach';

  final List<Map<String, dynamic>> _categories = [
    {'name': 'Beach', 'icon': Icons.beach_access},
    {'name': 'Mountain', 'icon': Icons.terrain},
    {'name': 'City', 'icon': Icons.location_city},
    {'name': 'Adventure', 'icon': Icons.explore},
    {'name': 'Wellness', 'icon': Icons.spa},
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Text(
            'Categories',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        AppSpacing.gapMd,
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Row(
            children: _categories.map((category) {
              final isSelected = _selectedCategory == category['name'];
              return Padding(
                padding: const EdgeInsets.only(right: 18.0),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCategory = category['name'];
                    });
                    if (widget.onCategorySelected != null) {
                      widget.onCategorySelected!(category['name']);
                    }
                  },
                  child: Column(
                    children: [
                      // Square Icon Box
                      Container(
                        width: 56.0,
                        height: 56.0,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.surfaceContainerLow,
                          borderRadius: AppRadii.borderLg,
                        ),
                        child: Icon(
                          category['icon'] as IconData,
                          color: isSelected
                              ? Colors.white
                              : AppColors.onSurface,
                          size: 24.0,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      // Text Label
                      Text(
                        category['name'] as String,
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.w500,
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
