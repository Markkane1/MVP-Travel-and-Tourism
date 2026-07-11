import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Standard centered loading indicator.
class LoadingIndicator extends StatelessWidget {
  final double size;
  final Color color;

  const LoadingIndicator({
    super.key,
    this.size = 36.0,
    this.color = AppColors.primary, // Brand navy as default indicator color
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: CircularProgressIndicator(color: color, strokeWidth: 3.0),
      ),
    );
  }
}
