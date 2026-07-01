import 'dart:async';
import 'dart:ui';
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
                  final last4 = cleanNo.length >= 4 ? cleanNo.substring(cleanNo.length - 4) : '9999';

                  await checkoutRepo.savePaymentMethod(
                    uid: authUser.uid,
                    cardBrand: brand,
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
            onRetry: () => ref.refresh(bookingDetailsProvider(widget.bookingId)),
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
                      _buildErrorBanner(),
                      AppSpacing.gapMd,
                    ],

                    // 2. Order Summary
                    _buildOrderSummaryCard(booking),
                    AppSpacing.gapLg,

                    // 3. Apple & Google Pay Digital Wallets (visual only with DEMO badge)
                    _buildDigitalWallets(booking),
                    AppSpacing.gapLg,

                    // 4. Divider
                    _buildOrPayWithCardDivider(),
                    AppSpacing.gapLg,

                    // 5. Credit or Debit Card inputs
                    _buildCreditCardForm(),
                    AppSpacing.gapLg,

                    // 6. Bank Transfer Alternative Option
                    _buildBankTransferRow(booking),
                    AppSpacing.gapLg,

                    // 7. Security copy footer
                    _buildTrustFootnote(),
                  ],
                ),
              ),

              // Sticky Bottom Payment Button
              _buildStickyBottomBar(booking),

              // Full-screen Blurring Processing Overlay
              if (_isProcessing) _buildProcessingOverlay(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildErrorBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.errorContainer,
        borderRadius: BorderRadius.circular(AppRadii.defaultRadius),
        border: Border.all(color: AppColors.error, width: 1.0),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 24.0),
          const SizedBox(width: 12.0),
          Expanded(
            child: Text(
              _errorMessage ?? AppStrings.checkout.paymentFailed,
              style: const TextStyle(
                color: AppColors.onErrorContainer,
                fontWeight: FontWeight.bold,
                fontSize: 14.0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummaryCard(Booking booking) {
    final theme = Theme.of(context);
    final String dateStr = '${booking.tourDate.day}/${booking.tourDate.month}/${booking.tourDate.year}';
    final int guestCount = booking.adults + booking.children;
    final String guestLabel = guestCount == 1 ? 'Guest' : 'Guests';

    return AppCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thumbnail Image
          Container(
            width: 72.0,
            height: 72.0,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadii.defaultRadius),
              image: DecorationImage(
                image: NetworkImage(booking.tourSnapshot.heroImageUrl),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 16.0),
          // Booking info summary
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  booking.tourSnapshot.title,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4.0),
                Text(
                  '$dateStr · $guestCount $guestLabel',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                if (booking.privateVehicle) ...[
                  const SizedBox(height: 4.0),
                  Row(
                    children: [
                      const Icon(Icons.airport_shuttle, size: 14.0, color: AppColors.secondary),
                      const SizedBox(width: 4.0),
                      Text(
                        'Private SUV included',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: AppColors.secondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDigitalWallets(Booking booking) {
    return Row(
      children: [
        Expanded(child: _buildWalletButton(AppStrings.checkout.applePayButton, Icons.apple, booking)),
        const SizedBox(width: 12.0),
        Expanded(child: _buildWalletButton(AppStrings.checkout.googlePayButton, Icons.android, booking)),
      ],
    );
  }

  Widget _buildWalletButton(String label, IconData icon, Booking booking) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        ElevatedButton(
          onPressed: () => _processPayment(booking),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 50.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadii.defaultRadius),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 20.0),
              const SizedBox(width: 8.0),
              Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0),
              ),
            ],
          ),
        ),
        // Mini DEMO badge overlay
        Positioned(
          top: -6.0,
          right: -4.0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
            decoration: BoxDecoration(
              color: AppColors.secondary,
              borderRadius: BorderRadius.circular(AppRadii.sm),
            ),
            child: Text(
              AppStrings.checkout.demoBadge,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 9.0,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOrPayWithCardDivider() {
    return const Row(
      children: [
        Expanded(child: Divider(color: AppColors.outlineVariant, thickness: 1.0)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.0),
          child: Text(
            'OR PAY WITH CARD',
            style: TextStyle(
              color: AppColors.onSurfaceVariant,
              fontWeight: FontWeight.bold,
              fontSize: 10.0,
              letterSpacing: 0.8,
            ),
          ),
        ),
        Expanded(child: Divider(color: AppColors.outlineVariant, thickness: 1.0)),
      ],
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
      onTap: () => context.push('/booking/${booking.id}/checkout/bank', extra: booking.totalPrice),
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

  Widget _buildTrustFootnote() {
    return Center(
      child: Text(
        AppStrings.checkout.footnote,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.onSurfaceVariant,
              fontSize: 10.0,
            ),
        textAlign: TextAlign.center,
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
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.lg)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              PrimaryButton(
                label: 'Pay \$${total.toInt().toString().replaceAllMapped(
                      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                      (Match m) => '${m[1]},',
                    )} →',
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
                        color: AppColors.onSurfaceVariant.withValues(alpha: 0.5),
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

  Widget _buildProcessingOverlay() {
    return Positioned.fill(
      child: Stack(
        children: [
          // Blurs checkout contents behind
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
              child: Container(color: Colors.black.withValues(alpha: 0.4)),
            ),
          ),
          // Rotating rings and lock icon
          const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    _RotatingRingAnim(),
                    Icon(Icons.lock, color: AppColors.primary, size: 28.0),
                  ],
                ),
                SizedBox(height: 20.0),
                Text(
                  'Processing Payment...',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Dynamic rotating ring graphic.
class _RotatingRingAnim extends StatefulWidget {
  const _RotatingRingAnim();

  @override
  State<_RotatingRingAnim> createState() => _RotatingRingAnimState();
}

class _RotatingRingAnimState extends State<_RotatingRingAnim>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _controller,
      child: Container(
        width: 80.0,
        height: 80.0,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.primary, width: 4.0),
        ),
        child: const Stack(
          children: [
            Positioned.fill(
              child: CircularProgressIndicator(
                value: 0.25,
                strokeWidth: 4.0,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.secondary),
                backgroundColor: Colors.transparent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
