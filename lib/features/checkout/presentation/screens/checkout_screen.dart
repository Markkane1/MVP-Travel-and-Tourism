import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/checkout_repository.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../core/widgets/error_state_view.dart';
import '../widgets/checkout_stateless_widgets.dart';
import '../../../booking/booking.dart';
import '../../../../core/config/env.dart';

enum _PaymentOption { bankTransfer, payOnArrival }

/// Checkout screen offering configured payment methods.
class CheckoutScreen extends ConsumerStatefulWidget {
  final String bookingId;
  const CheckoutScreen({super.key, required this.bookingId});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  _PaymentOption _selectedOption = Env.hasBankTransferDetails
      ? _PaymentOption.bankTransfer
      : _PaymentOption.payOnArrival;
  bool _isProcessing = false;
  String? _errorMessage;

  Future<void> _submitBooking(Booking booking) async {
    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    final method = _selectedOption == _PaymentOption.bankTransfer
        ? 'bank_transfer'
        : 'pay_on_arrival';

    final result = await ref
        .read(checkoutRepositoryProvider)
        .submitPaymentIntent(bookingId: booking.id, paymentMethod: method);

    if (!mounted) return;

    result.when(
      onSuccess: (_) {
        context.go(
          '/booking/${booking.id}/success',
          extra: {
            'bookingReferenceCode': booking.id.substring(0, 6).toUpperCase(),
          },
        );
      },
      onFailure: (e) {
        setState(() {
          _isProcessing = false;
          _errorMessage = e.message;
        });
      },
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
          'Secure Checkout',
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
                    // Error banner
                    if (_errorMessage != null) ...[
                      ErrorBannerWidget(errorMessage: _errorMessage!),
                      AppSpacing.gapMd,
                    ],

                    // Order summary
                    OrderSummaryCardWidget(booking: booking),
                    AppSpacing.gapLg,

                    // Section header
                    Text(
                      'Choose Payment Method',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.onSurface,
                      ),
                    ),
                    AppSpacing.gapMd,

                    if (Env.hasBankTransferDetails) ...[
                      _PaymentOptionCard(
                        icon: Icons.account_balance_outlined,
                        title: 'Bank Transfer',
                        subtitle:
                            'Transfer the amount to our account. We confirm your booking within 24 hours.',
                        isSelected:
                            _selectedOption == _PaymentOption.bankTransfer,
                        onTap: () => setState(
                          () => _selectedOption = _PaymentOption.bankTransfer,
                        ),
                      ),
                      AppSpacing.gapMd,
                    ],

                    // Option 2: Pay on Arrival
                    _PaymentOptionCard(
                      icon: Icons.payments_outlined,
                      title: 'Pay on Arrival',
                      subtitle:
                          'Reserve now, pay cash or card when you arrive at the destination.',
                      isSelected:
                          _selectedOption == _PaymentOption.payOnArrival,
                      onTap: () => setState(
                        () => _selectedOption = _PaymentOption.payOnArrival,
                      ),
                    ),
                    AppSpacing.gapLg,

                    // Bank transfer details (shown when selected)
                    if (_selectedOption == _PaymentOption.bankTransfer)
                      _BankDetailsCard(
                        totalPrice: booking.totalPrice,
                        currency: booking.currency,
                      ),

                    AppSpacing.gapLg,

                    // Info notice
                    _buildPendingNotice(theme),
                    AppSpacing.gapLg,

                    const TrustFootnoteWidget(),
                  ],
                ),
              ),

              // Sticky submit button
              _buildStickyBottomBar(booking),

              if (_isProcessing) const ProcessingOverlayWidget(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPendingNotice(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(AppRadii.defaultRadius),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, color: AppColors.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _selectedOption == _PaymentOption.bankTransfer
                  ? 'After submitting, our team will verify the booking and confirm the final payable amount before you transfer funds.'
                  : 'Your booking will be reserved. Our team will confirm it and you\'ll pay the final confirmed amount on the day of your tour.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStickyBottomBar(Booking booking) {
    final double total = booking.totalPrice;
    final label = _selectedOption == _PaymentOption.bankTransfer
        ? 'Submit & Get Bank Details'
        : 'Reserve Now — Pay on Arrival';

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
              Text(
                'Estimated total: ${booking.currency} ${total.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              PrimaryButton(
                buttonKey: const Key('checkout_submit_button'),
                label: label,
                onPressed: () => _submitBooking(booking),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Selectable payment option card.
class _PaymentOptionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _PaymentOptionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryContainer.withValues(alpha: 0.25)
              : AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppRadii.defaultRadius),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.outlineVariant,
            width: isSelected ? 2.0 : 1.0,
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary
                    : AppColors.surfaceContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 22,
                color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}

/// Bank account details card shown when bank transfer is selected.
class _BankDetailsCard extends StatelessWidget {
  final double totalPrice;
  final String currency;

  const _BankDetailsCard({required this.totalPrice, required this.currency});

  void _copyToClipboard(BuildContext context, String value, String label) {
    Clipboard.setData(ClipboardData(text: value));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label copied to clipboard'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.account_balance,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Bank Transfer Details',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSurface,
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          const _DetailRow(label: 'Bank', value: Env.bankName, onCopy: null),
          _DetailRow(
            label: 'Account Title',
            value: Env.bankAccountTitle,
            onCopy: () => _copyToClipboard(
              context,
              Env.bankAccountTitle,
              'Account title',
            ),
          ),
          _DetailRow(
            label: 'Account Number',
            value: Env.bankAccountNumber,
            onCopy: () => _copyToClipboard(
              context,
              Env.bankAccountNumber,
              'Account number',
            ),
          ),
          _DetailRow(
            label: 'IBAN',
            value: Env.bankIban,
            onCopy: () => _copyToClipboard(context, Env.bankIban, 'IBAN'),
          ),
          _DetailRow(
            label: 'Estimated Amount',
            value: '$currency ${totalPrice.toStringAsFixed(0)}',
            highlight: true,
            onCopy: () => _copyToClipboard(
              context,
              totalPrice.toStringAsFixed(0),
              'Amount',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Use your booking ID as the payment reference only after our team confirms the final payable amount.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.warning,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback? onCopy;
  final bool highlight;

  const _DetailRow({
    required this.label,
    required this.value,
    this.onCopy,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: highlight ? FontWeight.bold : FontWeight.w500,
                color: highlight ? AppColors.primary : AppColors.onSurface,
              ),
            ),
          ),
          if (onCopy != null)
            GestureDetector(
              onTap: onCopy,
              child: const Icon(
                Icons.copy_outlined,
                size: 16,
                color: AppColors.onSurfaceVariant,
              ),
            ),
        ],
      ),
    );
  }
}
