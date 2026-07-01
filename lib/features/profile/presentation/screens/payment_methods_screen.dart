// TODO: replace with real Stripe payment-method management (SetupIntent + customer.paymentMethods) once live payment processing is integrated. This screen currently stores only user-entered display data, never real card data.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../core/services/auth_service.dart';
import '../../domain/payment_method_item.dart';
import '../../data/profile_repository.dart';

class PaymentMethodsScreen extends ConsumerWidget {
  const PaymentMethodsScreen({super.key});

  Future<void> _deletePaymentMethod(BuildContext context, WidgetRef ref, String uid, String methodId) async {
    try {
      await ref.read(profileRepositoryProvider).deletePaymentMethod(
            uid: uid,
            methodId: methodId,
          );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment method removed.')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete payment method: ${e.toString()}')),
        );
      }
    }
  }

  void _showAddPaymentMethodSheet(BuildContext context, String uid) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.lg)),
      ),
      builder: (context) {
        return _AddPaymentMethodForm(uid: uid);
      },
    );
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
          // List of saved payment methods
          Expanded(
            child: methodsState.when(
              loading: () => const Center(child: LoadingIndicator()),
              error: (err, stack) => Center(child: Text('Error loading payment methods: $err')),
              data: (methods) {
                if (methods.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(AppSpacing.containerMargin),
                      child: Text(
                        'No payment methods saved yet.\nYou can save cards during checkout or add one here.',
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

          // Sticky bottom Add Button
          Padding(
            padding: const EdgeInsets.all(AppSpacing.containerMargin),
            child: PrimaryButton(
              label: 'Add Payment Method',
              onPressed: () => _showAddPaymentMethodSheet(context, user.uid),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardItem(BuildContext context, WidgetRef ref, String uid, PaymentMethodItem item) {
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
                      padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
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
                icon: const Icon(Icons.close, color: AppColors.onSurfaceVariant),
                onPressed: () => _deletePaymentMethod(context, ref, uid, item.id),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddPaymentMethodForm extends ConsumerStatefulWidget {
  final String uid;

  const _AddPaymentMethodForm({required this.uid});

  @override
  ConsumerState<_AddPaymentMethodForm> createState() => _AddPaymentMethodFormState();
}

class _AddPaymentMethodFormState extends ConsumerState<_AddPaymentMethodForm> {
  final _last4Controller = TextEditingController();
  String _selectedBrand = 'Visa';
  bool _isDefault = false;
  bool _isSaving = false;

  @override
  void dispose() {
    _last4Controller.dispose();
    super.dispose();
  }

  Future<void> _saveMethod() async {
    final cleanL4 = _last4Controller.text.trim();
    if (cleanL4.length != 4 || int.tryParse(cleanL4) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter exactly 4 digits.')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await ref.read(profileRepositoryProvider).savePaymentMethod(
            uid: widget.uid,
            brand: _selectedBrand,
            last4: cleanL4,
            isDefault: _isDefault,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment method added successfully.')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save card: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.containerMargin,
        right: AppSpacing.containerMargin,
        top: 24.0,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24.0,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Add Payment Method',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
          ),
          const SizedBox(height: 16.0),
          
          // Brand dropdown
          DropdownButtonFormField<String>(
            // ignore: deprecated_member_use
            value: _selectedBrand,
            decoration: const InputDecoration(
              labelText: 'Card Brand',
              border: OutlineInputBorder(),
            ),
            items: ['Visa', 'Mastercard', 'Amex', 'Other'].map((brand) {
              return DropdownMenuItem<String>(
                value: brand,
                child: Text(brand),
              );
            }).toList(),
            onChanged: (val) {
              if (val != null) {
                setState(() {
                  _selectedBrand = val;
                });
              }
            },
          ),
          AppSpacing.gapMd,

          // Last 4 field
          AppTextField(
            controller: _last4Controller,
            labelText: 'Last 4 Digits',
            hintText: 'e.g. 4321',
            keyboardType: TextInputType.number,
          ),
          AppSpacing.gapMd,

          // Default checkbox
          Row(
            children: [
              Checkbox(
                value: _isDefault,
                activeColor: AppColors.primary,
                onChanged: (val) {
                  setState(() {
                    _isDefault = val ?? false;
                  });
                },
              ),
              const Text('Set as default payment method'),
            ],
          ),
          AppSpacing.gapLg,

          PrimaryButton(
            label: 'Add Card',
            isLoading: _isSaving,
            onPressed: _saveMethod,
          ),
        ],
      ),
    );
  }
}
