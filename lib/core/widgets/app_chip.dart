import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Reusable stylized filter or category Chip.
class AppChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final ValueChanged<bool>? onSelected;
  final Widget? avatar;

  const AppChip({
    super.key,
    required this.label,
    this.isActive = false,
    this.onSelected,
    this.avatar,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ChoiceChip(
      label: Text(label),
      selected: isActive,
      onSelected: onSelected,
      avatar: avatar != null
          ? IconTheme(
              data: IconThemeData(
                color: isActive ? AppColors.onPrimary : AppColors.primary,
                size: 18.0,
              ),
              child: avatar!,
            )
          : null,
      labelStyle: theme.chipTheme.labelStyle?.copyWith(
        color: isActive ? AppColors.onPrimary : AppColors.primary,
        fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
      ),
      backgroundColor: AppColors.surfaceContainer,
      selectedColor: AppColors.primary,
      shape: const StadiumBorder(),
      side: BorderSide.none,
      pressElevation: 0.0,
      elevation: 0.0,
    );
  }
}
