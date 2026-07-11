import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/constants/app_strings.dart';

/// Screen displaying bank transfer wire details.
class BankTransferScreen extends StatelessWidget {
  final double amount;

  const BankTransferScreen({super.key, required this.amount});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final String amountStr =
        '\$${amount.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          AppStrings.checkout.bankTransferTitle,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.containerMargin),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Instruction Box
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: AppColors.primary,
                        size: 24.0,
                      ),
                      const SizedBox(width: 8.0),
                      Text(
                        'Wire Instructions',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.onSurface,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12.0),
                  Text(
                    AppStrings.checkout.bankTransferInstructions,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            AppSpacing.gapLg,

            // Bank details Card
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Wire Information',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  _buildDetailRow(
                    context,
                    'Bank Name',
                    AppStrings.checkout.bankName,
                  ),
                  _buildDivider(),
                  _buildDetailRow(
                    context,
                    'Account Number',
                    AppStrings.checkout.bankAccount.replaceFirst(
                      'Account: ',
                      '',
                    ),
                  ),
                  _buildDivider(),
                  _buildDetailRow(
                    context,
                    'Routing Code',
                    AppStrings.checkout.bankRouting.replaceFirst(
                      'Routing/IBAN: ',
                      '',
                    ),
                  ),
                  _buildDivider(),
                  _buildDetailRow(
                    context,
                    'Total Amount',
                    amountStr,
                    valueColor: AppColors.primary,
                    isBold: true,
                  ),
                ],
              ),
            ),
            AppSpacing.gapLg,

            // Support Note
            Center(
              child: Text(
                'Please send screenshot confirmation to support@mvptravel.com after transfer completion.',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: AppColors.onSurfaceVariant,
                  fontSize: 11.0,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    String label,
    String value, {
    Color? valueColor,
    bool isBold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.onSurfaceVariant),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: valueColor ?? AppColors.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      height: 16.0,
      color: AppColors.outlineVariant,
      thickness: 1.0,
    );
  }
}
