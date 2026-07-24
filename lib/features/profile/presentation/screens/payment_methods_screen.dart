import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../core/services/auth_service.dart';
import '../../domain/payment_method_item.dart';
import '../../data/profile_repository.dart';

class PaymentMethodsScreen extends ConsumerWidget {
  const PaymentMethodsScreen({super.key});

  Future<void> _deletePaymentMethod(
    BuildContext context,
    WidgetRef ref,
    String uid,
    String methodId,
  ) async {
    try {
      final result = await ref
          .read(profileRepositoryProvider)
          .deletePaymentMethod(uid: uid, methodId: methodId);

      await result.when(
        onSuccess: (_) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Payment method removed.')),
            );
          }
        },
        onFailure: (exception) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Failed to delete payment method: ${exception.message}',
                ),
              ),
            );
          }
        },
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete payment method: ${e.toString()}'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authServiceProvider).currentUser;
    if (user == null) {
      return const Scaffold(body: Center(child: Text('Please log in.')));
    }

    final methodsState = ref.watch(paymentMethodsStreamProvider(user.uid));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Payment Methods',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: methodsState.when(
              loading: () => const Center(child: LoadingIndicator()),
              error: (err, stack) =>
                  Center(child: Text('Error loading payment methods: $err')),
              data: (methods) {
                if (methods.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(AppSpacing.containerMargin),
                      child: Text(
                        'No saved payment methods.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.onSurfaceVariant),
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(AppSpacing.containerMargin),
                  itemCount: methods.length,
                  itemBuilder: (context, index) {
                    final item = methods[index];
                    return _buildCardItem(context, ref, user.uid, item);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardItem(
    BuildContext context,
    WidgetRef ref,
    String uid,
    PaymentMethodItem item,
  ) {
    IconData cardIcon = Icons.credit_card;
    if (item.brand.toLowerCase() == 'visa') {
      cardIcon = Icons.payment;
    } else if (item.brand.toLowerCase() == 'mastercard') {
      cardIcon = Icons.credit_card_outlined;
    } else if (item.brand.toLowerCase() == 'amex') {
      cardIcon = Icons.credit_card;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: AppCard(
        child: Row(
          children: [
            Icon(cardIcon, color: AppColors.primary, size: 28.0),
            const SizedBox(width: 16.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${item.brand} •••• ${item.last4}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.onSurface,
                    ),
                  ),
                  if (item.isDefault) ...[
                    const SizedBox(height: 4.0),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6.0,
                        vertical: 2.0,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer,
                        borderRadius: BorderRadius.circular(AppRadii.sm),
                      ),
                      child: const Text(
                        'Default',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 9.0,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Semantics(
              label: 'Remove payment method',
              button: true,
              child: IconButton(
                tooltip: 'Remove payment method',
                icon: const Icon(
                  Icons.close,
                  color: AppColors.onSurfaceVariant,
                ),
                onPressed: () =>
                    _deletePaymentMethod(context, ref, uid, item.id),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
