import 'package:flutter/material.dart';


import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/app_text_field.dart';

class LogisticsCardWidget extends StatelessWidget {
  final TextEditingController pickupController;
  final TextEditingController specialRequestsController;
  final String? validationWarning;
  final ValueChanged<String>? onPickupChanged;

  const LogisticsCardWidget({
    super.key,
    required this.pickupController,
    required this.specialRequestsController,
    this.validationWarning,
    this.onPickupChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        boxShadow: AppShadows.level2,
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppTextField(
            controller: pickupController,
            labelText: AppStrings.booking.pickupLocationLabel,
            hintText: AppStrings.booking.pickupLocationHint,
            prefixIcon: const Icon(Icons.hotel, size: 20.0),
            maxLength: 200,
            onChanged: onPickupChanged,
          ),
          AppSpacing.gapMd,
          AppTextField(
            controller: specialRequestsController,
            labelText: AppStrings.booking.specialRequestsLabel,
            hintText: AppStrings.booking.specialRequestsHint,
            maxLines: 4,
            maxLength: 500,
            keyboardType: TextInputType.multiline,
            textInputAction: TextInputAction.newline,
          ),
        ],
      ),
    );
  }
}
