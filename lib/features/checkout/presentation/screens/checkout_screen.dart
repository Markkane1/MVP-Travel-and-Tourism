import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/checkout_repository.dart';
import '../../../../core/services/auth_service.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/app_card.dart';
import '../widgets/checkout_stateless_widgets.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../core/widgets/error_state_view.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/result.dart';
import '../../../booking/booking.dart';
import '../../domain/payment_service.dart';
import '../../data/mock_payment_service.dart';

/// Screen managing simulated checkout and payments.
class CheckoutScreen extends ConsumerStatefulWidget {
  final String bookingId;

  const CheckoutScreen({super.key, required this.bookingId});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _nameController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();

  bool _saveCard = false;
  bool _isProcessing = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  Future<void> _processPayment(Booking booking) async {
    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    try {
      final PaymentService paymentService = ref.read(paymentServiceProvider);
      final Result<PaymentOutcome> paymentResult = await paymentService.pay(
        bookingId: booking.id,
        amount: booking.totalPrice,
        currency: booking.currency,
      );

      await paymentResult.when(
        onSuccess: (outcome) async {
          final checkoutRepo = ref.read(checkoutRepositoryProvider);
          final confirmResult = await checkoutRepo.confirmBooking(booking.id);

          await confirmResult.when(
            onSuccess: (data) async {
              // If the user selected to save the card for future bookings, save display-only details
              if (_saveCard) {
                final authUser = ref.read(authServiceProvider).currentUser;
                if (authUser != null) {
                  String brand = 'Visa';
                  final cardNo = _cardNumberController.text.trim();
                  if (cardNo.startsWith('3')) {
                    brand = 'Amex';
                  } else if (cardNo.startsWith('5')) {
                    brand = 'Mastercard';
                  } else if (cardNo.startsWith('4')) {
                    brand = 'Visa';
                  } else {
                    brand = 'Other';
                  }

                  final cleanNo = cardNo.replaceAll(RegExp(r'\s+'), '');
                  final last4 = cleanNo.length >= 4
                      ? cleanNo.substring(cleanNo.length - 4)
                      : '9999';

                  await checkoutRepo.savePaymentMethod(
                    uid: authUser.uid,
                    brand: brand,
                    last4: last4,
                  );
                }
              }

              if (mounted) {
                context.go('/booking/${booking.id}/success', extra: data);
              }
            },
            onFailure: (exception) {
              if (mounted) {
                setState(() {
                  _isProcessing = false;
                  _errorMessage = exception.message;
                });
              }
            },
          );
        },
        onFailure: (exception) {
          if (mounted) {
            setState(() {
              _isProcessing = false;
              _errorMessage = exception.message;
            });
          }
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _errorMessage = 'Payment execution failed: ${e.toString()}';
        });
      }
    }
  }

  void _toggleMockFailure() {
    setState(() {
      MockPaymentService.shouldFail = !MockPaymentService.shouldFail;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          MockPaymentService.shouldFail
              ? 'DEBUG: Simulated payment failure ENABLED'
              : 'DEBUG: Simulated payment failure DISABLED',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bookingState = ref.watch(bookingDetailsProvider(widget.bookingId));
    final theme = Theme.of(context);

    return Scaffold(
      key: const Key('checkout_screen'),
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          AppStrings.checkout.title,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
          onPressed: () => context.pop(),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Icon(Icons.lock_outline, color: AppColors.onSurfaceVariant),
          ),
        ],
      ),
      body: bookingState.when(
        loading: () => const Center(child: LoadingIndicator()),
        error: (err, stack) => Center(
          child: ErrorStateView(
            message: err.toString(),
            onRetry: () =>
                ref.refresh(bookingDetailsProvider(widget.bookingId)),
          ),
        ),
        data: (booking) {
          if (booking == null) {
            return const Center(child: Text('Booking details not found.'));
          }

          return Stack(
            children: [
              // Main Scrollable Checkout Flow
              SingleChildScrollView(
                padding: const EdgeInsets.only(
                  left: AppSpacing.containerMargin,
                  right: AppSpacing.containerMargin,
                  top: AppSpacing.sm,
                  bottom: 140.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Error Banner
                    if (_errorMessage != null) ...[
                      ErrorBannerWidget(
                        errorMessage:
                            _errorMessage ?? AppStrings.checkout.paymentFailed,
                      ),
                      AppSpacing.gapMd,
                    ],

                    // 2. Order Summary
                    OrderSummaryCardWidget(booking: booking),
                    AppSpacing.gapLg,

                    // 3. Apple & Google Pay Digital Wallets (visual only with DEMO badge)
                    DigitalWalletsWidget(
                      booking: booking,
                      onPay: _processPayment,
                    ),
                    AppSpacing.gapLg,

                    // 4. Divider
                    const OrPayWithCardDividerWidget(),
                    AppSpacing.gapLg,

                    // 5. Credit or Debit Card inputs
                    _buildCreditCardForm(),
                    AppSpacing.gapLg,

                    // 6. Bank Transfer Alternative Option
                    _buildBankTransferRow(booking),
                    AppSpacing.gapLg,

                    // 7. Security copy footer
                    const TrustFootnoteWidget(),
                  ],
                ),
              ),

              // Sticky Bottom Payment Button
              _buildStickyBottomBar(booking),

              // Full-screen Blurring Processing Overlay
              if (_isProcessing) const ProcessingOverlayWidget(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCreditCardForm() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Credit or Debit Card',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.onSurface,
            ),
          ),
          AppSpacing.gapMd,
          AppTextField(
            controller: _nameController,
            labelText: AppStrings.checkout.cardholderNameLabel,
            hintText: AppStrings.checkout.cardholderNameHint,
          ),
          AppSpacing.gapMd,
          AppTextField(
            controller: _cardNumberController,
            labelText: AppStrings.checkout.cardNumberLabel,
            hintText: AppStrings.checkout.cardNumberHint,
            keyboardType: TextInputType.number,
          ),
          AppSpacing.gapMd,
          Row(
            children: [
              Expanded(
                child: AppTextField(
                  controller: _expiryController,
                  labelText: AppStrings.checkout.expiryLabel,
                  hintText: AppStrings.checkout.expiryHint,
                  keyboardType: TextInputType.datetime,
                ),
              ),
              const SizedBox(width: 16.0),
              Expanded(
                child: AppTextField(
                  controller: _cvvController,
                  labelText: AppStrings.checkout.cvvLabel,
                  hintText: AppStrings.checkout.cvvHint,
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          AppSpacing.gapMd,
          Row(
            children: [
              Checkbox(
                value: _saveCard,
                activeColor: AppColors.primary,
                onChanged: (val) {
                  setState(() {
                    _saveCard = val ?? false;
                  });
                },
              ),
              Expanded(
                child: Text(
                  AppStrings.checkout.saveCardLabel,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBankTransferRow(Booking booking) {
    return GestureDetector(
      onTap: () => context.push(
        '/booking/${booking.id}/checkout/bank',
        extra: booking.totalPrice,
      ),
      child: AppCard(
        child: Row(
          children: [
            const Icon(Icons.account_balance, color: AppColors.primary),
            const SizedBox(width: 16.0),
            Expanded(
              child: Text(
                AppStrings.checkout.bankTransferRow,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSurface,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.onSurfaceVariant),
          ],
        ),
      ),
    );
  }

  Widget _buildStickyBottomBar(Booking booking) {
    final double total = booking.totalPrice;

    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: AppShadows.level3,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadii.lg),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              PrimaryButton(
                buttonKey: const Key('checkout_pay_button'),
                label: 'Pay ${booking.currency} ${total.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} →',
                onPressed: () => _processPayment(booking),
                // Hidden debug toggle enabled on long-press only in debug builds
                // Using standard Gesture wrapper in build pipeline to capture trigger
              ),
              if (kDebugMode) ...[
                const SizedBox(height: 8.0),
                GestureDetector(
                  onLongPress: _toggleMockFailure,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    alignment: Alignment.center,
                    child: Text(
                      'DEBUG: Long-press here to toggle payment failure scenario',
                      style: TextStyle(
                        fontSize: 9.0,
                        color: AppColors.onSurfaceVariant.withValues(
                          alpha: 0.5,
                        ),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Dynamic rotating ring graphic.
