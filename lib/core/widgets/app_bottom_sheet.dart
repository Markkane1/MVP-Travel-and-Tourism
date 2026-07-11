import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radii.dart';

/// Custom Bottom Sheet container with top rounded corners and drag handle.
class AppBottomSheet extends StatelessWidget {
  final Widget child;
  final String? title;

  const AppBottomSheet({super.key, required this.child, this.title});

  /// Static helper to easily show this bottom sheet modal.
  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    String? title,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => AppBottomSheet(title: title, child: child),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);

    return Container(
      margin: EdgeInsets.only(top: mediaQuery.padding.top + 48.0),
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerLowest, // Pure white
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppRadii.xl),
          topRight: Radius.circular(AppRadii.xl),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          const SizedBox(height: 12.0),
          Center(
            child: Container(
              width: 36.0,
              height: 4.0,
              decoration: const BoxDecoration(
                color: AppColors.surfaceDim,
                borderRadius: AppRadii.borderFull,
              ),
            ),
          ),
          const SizedBox(height: 8.0),
          if (title != null) ...[
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 8.0,
              ),
              child: Text(
                title!,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSurface,
                ),
              ),
            ),
            const Divider(color: AppColors.surfaceContainer),
          ],
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 24.0,
                right: 24.0,
                top: title == null ? 16.0 : 8.0,
                bottom: mediaQuery.viewInsets.bottom + 24.0,
              ),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}
