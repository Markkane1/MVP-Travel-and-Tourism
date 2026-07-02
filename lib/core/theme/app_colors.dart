import 'package:flutter/material.dart';

/// App color design tokens as defined in the design specification.
class AppColors {
  AppColors._();

  static const Color surface = Color(0xFFF6FAFF);
  static const Color surfaceDim = Color(0xFFD2DBE4);
  static const Color surfaceBright = Color(0xFFF6FAFF);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFECF5FE);
  static const Color surfaceContainer = Color(0xFFE6EFF8);
  static const Color surfaceContainerHigh = Color(0xFFE0E9F2);
  static const Color surfaceContainerHighest = Color(0xFFDBE4ED);
  static const Color onSurface = Color(0xFF141D23);
  static const Color onSurfaceVariant = Color(0xFF43474E);
  static const Color inverseSurface = Color(0xFF293138);
  static const Color inverseOnSurface = Color(0xFFE9F2FB);
  static const Color outline = Color(0xFF74777F);
  static const Color outlineVariant = Color(0xFFC4C6CF);
  static const Color surfaceTint = Color(0xFF455F88);

  static const Color primary = Color(0xFF000D22); // Navy - brand primary
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFF002349);
  static const Color onPrimaryContainer = Color(0xFF718BB7);
  static const Color inversePrimary = Color(0xFFADC8F6);

  static const Color secondary = Color(0xFF775A19); // Gold - premium accents
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFFFED488);
  static const Color onSecondaryContainer = Color(0xFF785A1A);

  static const Color tertiary = Color(0xFF0C0E0F);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color tertiaryContainer = Color(0xFF212425);
  static const Color onTertiaryContainer = Color(0xFF898B8C);

  static const Color error = Color(0xFFBA1A1A);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onErrorContainer = Color(0xFF93000A);

  static const Color primaryFixed = Color(0xFFD5E3FF);
  static const Color primaryFixedDim = Color(0xFFADC8F6);
  static const Color onPrimaryFixed = Color(0xFF001B3C);
  static const Color onPrimaryFixedVariant = Color(0xFF2C476F);

  static const Color secondaryFixed = Color(0xFFFFDEA5);
  static const Color secondaryFixedDim = Color(0xFFE9C176);
  static const Color onSecondaryFixed = Color(0xFF261900);
  static const Color onSecondaryFixedVariant = Color(0xFF5D4201);

  static const Color tertiaryFixed = Color(0xFFE1E3E4);
  static const Color tertiaryFixedDim = Color(0xFFC5C7C8);
  static const Color onTertiaryFixed = Color(0xFF191C1D);
  static const Color onTertiaryFixedVariant = Color(0xFF454748);

  static const Color background = Color(0xFFF6FAFF);
  static const Color onBackground = Color(0xFF141D23);
  static const Color surfaceVariant = Color(0xFFDBE4ED);

  // Semantic status colors
  static const Color success = Color(0xFF2E7D32);
  static const Color successContainer = Color(0xFFE8F5E9);
  static const Color warning = Color(0xFFE65100);
  static const Color warningContainer = Color(0xFFFFF3E0);
  static const Color shadow = Color(0xFF000000);
  static const Color level2Shadow = Color(0x0D002349);
  static const Color level3Shadow = Color(0x1A002349);

  /// Canonical Flutter [ColorScheme] wired from tokens.
  static const ColorScheme lightScheme = ColorScheme(
    brightness: Brightness.light,
    primary: primary,
    onPrimary: onPrimary,
    primaryContainer: primaryContainer,
    onPrimaryContainer: onPrimaryContainer,
    secondary: secondary,
    onSecondary: onSecondary,
    secondaryContainer: secondaryContainer,
    onSecondaryContainer: onSecondaryContainer,
    tertiary: tertiary,
    onTertiary: onTertiary,
    tertiaryContainer: tertiaryContainer,
    onTertiaryContainer: onTertiaryContainer,
    error: error,
    onError: onError,
    errorContainer: errorContainer,
    onErrorContainer: onErrorContainer,
    surface: surface,
    onSurface: onSurface,
    onSurfaceVariant: onSurfaceVariant,
    outline: outline,
    outlineVariant: outlineVariant,
    shadow: shadow,
    inverseSurface: inverseSurface,
    onInverseSurface: inverseOnSurface,
    inversePrimary: inversePrimary,
    surfaceTint: surfaceTint,
  );
}
