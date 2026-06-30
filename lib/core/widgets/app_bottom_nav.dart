import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Reusable navigation item model.
class AppBottomNavItem {
  final IconData activeIcon;
  final IconData inactiveIcon;
  final String label;

  const AppBottomNavItem({
    required this.activeIcon,
    required this.inactiveIcon,
    required this.label,
  });
}

/// A custom, premium bottom navigation bar displaying 5 persistent shell branches.
class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<AppBottomNavItem> items;

  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerLowest, // White
        border: Border(
          top: BorderSide(
            color: AppColors.surfaceContainer,
            width: 1.0,
          ),
        ),
      ),
      padding: EdgeInsets.only(
        top: AppSpacing.base,
        bottom: bottomPadding > 0 ? bottomPadding : AppSpacing.base,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (index) {
          final item = items[index];
          final isActive = index == currentIndex;

          return Expanded(
            child: InkWell(
              onTap: () => onTap(index),
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: isActive ? AppColors.primary : Colors.transparent, // Navy circle if active
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isActive ? item.activeIcon : item.inactiveIcon,
                      color: isActive ? AppColors.onPrimary : AppColors.onSurfaceVariant,
                      size: 24.0,
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    item.label,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: isActive ? AppColors.primary : AppColors.onSurfaceVariant,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
