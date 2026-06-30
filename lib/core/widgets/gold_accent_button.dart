import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radii.dart';

/// A premium Gold Accent Button used exclusively for key CTAs (e.g., "Book Now", "Claim Offer").
class GoldAccentButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final double? width;
  final double height;
  final bool isPill;

  const GoldAccentButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.width = double.infinity,
    this.height = 54.0,
    this.isPill = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderRadius = isPill ? AppRadii.borderFull : AppRadii.borderDefault;

    return SizedBox(
      width: width,
      height: height,
      child: Opacity(
        opacity: onPressed == null ? 0.38 : 1.0,
        child: ElevatedButton(
          onPressed: onPressed,
          style: theme.elevatedButtonTheme.style?.copyWith(
            backgroundColor: WidgetStateProperty.all(AppColors.secondary),
            foregroundColor: WidgetStateProperty.all(AppColors.onSecondary),
            shape: WidgetStateProperty.all(
              RoundedRectangleBorder(borderRadius: borderRadius),
            ),
          ),
          child: Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              color: AppColors.onSecondary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
