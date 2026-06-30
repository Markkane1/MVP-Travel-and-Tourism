import 'package:flutter/material.dart';

/// App elevation and BoxShadow constants.
class AppShadows {
  AppShadows._();

  /// Level 1: Flat surface (no shadow)
  static const List<BoxShadow> level1 = [];

  /// Level 2: Cards, widgets
  static const List<BoxShadow> level2 = [
    BoxShadow(
      color: Color(0x0D002349), // Navy with 5% opacity
      blurRadius: 20.0,
      offset: Offset(0, 4),
    ),
  ];

  /// Level 3: Floating buttons, dialogs, modals, payment overlays
  static const List<BoxShadow> level3 = [
    BoxShadow(
      color: Color(0x1A002349), // Navy with 10% opacity
      blurRadius: 32.0,
      offset: Offset(0, 8),
    ),
  ];
}
