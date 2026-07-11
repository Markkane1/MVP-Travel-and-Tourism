import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../constants/app_strings.dart';
import 'secondary_button.dart';

/// Reusable Error State View for error handling.
class ErrorStateView extends StatelessWidget {
  final String? message;
  final VoidCallback onRetry;

  const ErrorStateView({super.key, this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final errorMessage = message ?? AppStrings.common.genericError;

    return Center(
      child: Padding(
        padding: AppSpacing.paddingLg,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_outlined,
              size: 64.0,
              color: AppColors.error,
            ),
            AppSpacing.gapLg,
            Text(
              'Error Occurred',
              style: theme.textTheme.headlineMedium?.copyWith(
                color: AppColors.onSurface,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            AppSpacing.gapBase,
            Text(
              errorMessage,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            AppSpacing.gapXl,
            SecondaryButton(
              label: AppStrings.common.retryButton,
              onPressed: onRetry,
              width: 160.0,
            ),
          ],
        ),
      ),
    );
  }
}
