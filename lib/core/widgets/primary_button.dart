import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radii.dart';

/// Reusable full-width Primary Button.
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final double? width;
  final double height;
  final bool isPill;
  final Key? buttonKey;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.width = double.infinity,
    this.height = 54.0,
    this.isPill = false,
    this.buttonKey,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderRadius = isPill ? AppRadii.borderFull : AppRadii.borderDefault;

    return SizedBox(
      width: width,
      height: height,
      child: Opacity(
        opacity: onPressed == null || isLoading ? 0.38 : 1.0,
        child: ElevatedButton(
          key: buttonKey,
          onPressed: isLoading ? null : onPressed,
          style: theme.elevatedButtonTheme.style?.copyWith(
            shape: WidgetStateProperty.all(
              RoundedRectangleBorder(borderRadius: borderRadius),
            ),
          ),
          child: isLoading
              ? const SizedBox(
                  width: 24.0,
                  height: 24.0,
                  child: CircularProgressIndicator(
                    color: AppColors.onPrimary,
                    strokeWidth: 2.5,
                  ),
                )
              : Text(
                  label,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: AppColors.onPrimary,
                  ),
                ),
        ),
      ),
    );
  }
}
