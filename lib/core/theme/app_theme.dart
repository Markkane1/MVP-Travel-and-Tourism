import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';
import 'app_radii.dart';

/// Central theme provider for the light-mode only application theme.
class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    final colors = AppColors.lightScheme;
    final textTheme = AppTypography.buildTextTheme(colors);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colors,
      scaffoldBackgroundColor: colors.surface,
      textTheme: textTheme,
      
      // Card Theme
      cardTheme: const CardThemeData(
        color: AppColors.surfaceContainerLowest,
        elevation: 0.0,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadii.borderLg,
        ),
      ),

      // App Bar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        scrolledUnderElevation: 0.0,
        centerTitle: true,
        iconTheme: IconThemeData(color: colors.onSurface),
        actionsIconTheme: IconThemeData(color: colors.onSurface),
        titleTextStyle: AppTypography.headlineMd.copyWith(
          color: colors.onSurface,
        ),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: colors.onPrimary,
          elevation: 0.0,
          textStyle: AppTypography.labelMd,
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadii.borderDefault,
          ),
        ),
      ),

      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colors.primary,
          side: BorderSide(color: colors.primary, width: 1.5),
          textStyle: AppTypography.labelMd,
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadii.borderDefault,
          ),
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colors.primary,
          textStyle: AppTypography.labelMd,
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        ),
      ),

      // Input Decoration Theme (Fields)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceContainer,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        border: const OutlineInputBorder(
          borderRadius: AppRadii.borderDefault,
          borderSide: BorderSide.none,
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: AppRadii.borderDefault,
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadii.borderDefault,
          borderSide: BorderSide(color: colors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadii.borderDefault,
          borderSide: BorderSide(color: colors.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppRadii.borderDefault,
          borderSide: BorderSide(color: colors.error, width: 2.0),
        ),
        labelStyle: AppTypography.bodyMd.copyWith(color: colors.onSurfaceVariant),
        hintStyle: AppTypography.bodyMd.copyWith(color: colors.outline),
        errorStyle: AppTypography.labelSm.copyWith(color: colors.error),
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceContainer,
        selectedColor: colors.primary,
        disabledColor: AppColors.surfaceContainer.withValues(alpha: 0.38),
        secondarySelectedColor: colors.primary,
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        shape: const StadiumBorder(),
        labelStyle: AppTypography.labelSm.copyWith(color: colors.onSurface),
        secondaryLabelStyle: AppTypography.labelSm.copyWith(color: colors.onPrimary),
        checkmarkColor: colors.onPrimary,
        side: BorderSide.none,
      ),

      // Bottom Navigation Theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.surfaceContainerLowest,
        selectedItemColor: colors.primary,
        unselectedItemColor: colors.onSurfaceVariant,
        selectedLabelStyle: AppTypography.labelSm.copyWith(color: colors.primary),
        unselectedLabelStyle: AppTypography.labelSm.copyWith(color: colors.onSurfaceVariant),
        type: BottomNavigationBarType.fixed,
        elevation: 8.0,
      ),
    );
  }
}
