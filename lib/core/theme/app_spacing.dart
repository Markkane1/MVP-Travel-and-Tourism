import 'package:flutter/material.dart';

/// App spacing tokens as defined in the design system.
class AppSpacing {
  AppSpacing._();

  static const double xs = 4.0;
  static const double base = 8.0;
  static const double sm = 12.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double containerMargin = 20.0;
  static const double gutter = 16.0;

  // Reusable padding edge insets
  static const EdgeInsets paddingXs = EdgeInsets.all(xs);
  static const EdgeInsets paddingBase = EdgeInsets.all(base);
  static const EdgeInsets paddingSm = EdgeInsets.all(sm);
  static const EdgeInsets paddingMd = EdgeInsets.all(md);
  static const EdgeInsets paddingLg = EdgeInsets.all(lg);
  static const EdgeInsets paddingXl = EdgeInsets.all(xl);

  // Horizontal and Vertical gap boxes for layouts
  static const SizedBox gapXs = SizedBox(width: xs, height: xs);
  static const SizedBox gapBase = SizedBox(width: base, height: base);
  static const SizedBox gapSm = SizedBox(width: sm, height: sm);
  static const SizedBox gapMd = SizedBox(width: md, height: md);
  static const SizedBox gapLg = SizedBox(width: lg, height: lg);
  static const SizedBox gapXl = SizedBox(width: xl, height: xl);
}
