import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radii.dart';

/// Reusable outlined Secondary Button.
class SecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Widget? icon;
  final double? width;
  final double height;
  final bool isPill;

  const SecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
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
        child: OutlinedButton(
          onPressed: onPressed,
          style: theme.outlinedButtonTheme.style?.copyWith(
            shape: WidgetStateProperty.all(
              RoundedRectangleBorder(borderRadius: borderRadius),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                icon!,
                const SizedBox(width: 8.0),
              ],
              Text(
                label,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
