import 'package:flutter/material.dart';
import 'app_colors.dart';

/// App elevation and BoxShadow constants.
class AppShadows {
  AppShadows._();

  /// Level 1: Flat surface (no shadow)
  static const List<BoxShadow> level1 = [];

  /// Level 2: Cards, widgets
  static const List<BoxShadow> level2 = [
    BoxShadow(
      color: AppColors.level2Shadow,
      blurRadius: 20.0,
      offset: Offset(0, 4),
    ),
  ];

  /// Level 3: Floating buttons, dialogs, modals, payment overlays
  static const List<BoxShadow> level3 = [
    BoxShadow(
      color: AppColors.level3Shadow,
      blurRadius: 32.0,
      offset: Offset(0, 8),
    ),
  ];
}
