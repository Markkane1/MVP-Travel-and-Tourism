import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radii.dart';
import '../theme/app_spacing.dart';
import '../theme/app_shadows.dart';

/// Reusable premium Card container styled with a Level 2 shadow.
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final BorderRadiusGeometry borderRadius;
  final Color backgroundColor;

  const AppCard({
    super.key,
    required this.child,
    this.padding = AppSpacing.paddingLg, // 24px internal padding
    this.borderRadius = AppRadii.borderLg, // 16px radius
    this.backgroundColor = AppColors.surfaceContainerLowest, // White
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(boxShadow: AppShadows.level2),
      child: Material(
        color: backgroundColor,
        borderRadius: borderRadius,
        clipBehavior: Clip.antiAlias,
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}
