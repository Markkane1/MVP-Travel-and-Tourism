import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// App typography definitions matching the Montserrat & Inter spec.
class AppTypography {
  AppTypography._();

  // Montserrat constants (Display/Headline)
  static final TextStyle displayLg = GoogleFonts.montserrat(
    fontWeight: FontWeight.w700,
    fontSize: 40.0,
    height: 48.0 / 40.0,
    letterSpacing: -0.02 * 40.0,
  );

  static final TextStyle headlineLg = GoogleFonts.montserrat(
    fontWeight: FontWeight.w600,
    fontSize: 28.0,
    height: 36.0 / 28.0,
  );

  static final TextStyle headlineLgMobile = GoogleFonts.montserrat(
    fontWeight: FontWeight.w600,
    fontSize: 24.0,
    height: 32.0 / 24.0,
  );

  static final TextStyle headlineMd = GoogleFonts.montserrat(
    fontWeight: FontWeight.w600,
    fontSize: 20.0,
    height: 28.0 / 20.0,
  );

  // Inter constants (Body/Label)
  static final TextStyle bodyLg = GoogleFonts.inter(
    fontWeight: FontWeight.w400,
    fontSize: 18.0,
    height: 28.0 / 18.0,
  );

  static final TextStyle bodyMd = GoogleFonts.inter(
    fontWeight: FontWeight.w400,
    fontSize: 16.0,
    height: 24.0 / 16.0,
  );

  static final TextStyle labelMd = GoogleFonts.inter(
    fontWeight: FontWeight.w600,
    fontSize: 14.0,
    height: 20.0 / 14.0,
    letterSpacing: 0.01 * 14.0,
  );

  static final TextStyle labelSm = GoogleFonts.inter(
    fontWeight: FontWeight.w500,
    fontSize: 12.0,
    height: 16.0 / 12.0,
    letterSpacing: 0.03 * 12.0,
  );

  /// Assembles the shared text theme.
  /// Standard slot mapping:
  /// - [displayLarge] maps to displayLg
  /// - [headlineLarge] maps to headlineLg (or headlineLgMobile depending on device contexts)
  /// - [headlineMedium] maps to headlineMd
  /// - [bodyLarge] maps to bodyLg
  /// - [bodyMedium] maps to bodyMd
  /// - [labelLarge] maps to labelMd
  /// - [labelSmall] maps to labelSm
  static TextTheme buildTextTheme(ColorScheme colors) {
    return TextTheme(
      displayLarge: displayLg.copyWith(color: colors.onSurface),
      headlineLarge: headlineLg.copyWith(color: colors.onSurface),
      headlineMedium: headlineMd.copyWith(color: colors.onSurface),
      bodyLarge: bodyLg.copyWith(color: colors.onSurface),
      bodyMedium: bodyMd.copyWith(color: colors.onSurface),
      labelLarge: labelMd.copyWith(color: colors.onSurface),
      labelSmall: labelSm.copyWith(color: colors.onSurface),
    );
  }
}
