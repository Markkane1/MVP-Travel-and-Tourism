import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../core/widgets/error_state_view.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/services/auth_service.dart';
import '../../../explore/domain/tour.dart';
import '../../../tour_details/tour_details.dart';
import '../../domain/booking.dart';
import '../../data/booking_repository.dart';
import '../../domain/usecases/calculate_booking_price_use_case.dart';

/// Screen allowing the traveler to configure dates, participants, and logistics for a tour booking.
class BookingScreen extends ConsumerStatefulWidget {
  final String tourId;

  const BookingScreen({super.key, required this.tourId});

  @override
  ConsumerState<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends ConsumerState<BookingScreen> {
  DateTime? _selectedDate;
  int _adultsCount = 1;
  int _childrenCount = 0;
  bool _privateVehicle = false;
  String _groupSizeOption = 'Shared';

  final _pickupController = TextEditingController();
  final _specialRequestsController = TextEditingController();
  String? _validationWarning;
  bool _isSubmitting = false;

  late final CalculateBookingPriceUseCase _priceCalculator;

  @override
  void initState() {
    super.initState();
    _priceCalculator = CalculateBookingPriceUseCase();
  }

  @override
  void dispose() {
    _pickupController.dispose();
    _specialRequestsController.dispose();
    super.dispose();
  }

  void _onGroupSizeSelected(String option) {
    setState(() {
      _groupSizeOption = option;
      if (option == 'Max 6' || option == 'Max 12') {
        _privateVehicle = true;
      }
      _validationWarning = null;
    });
  }

  void _onPrivateVehicleToggled(bool value) {
    if (!value && (_groupSizeOption == 'Max 6' || _groupSizeOption == 'Max 12')) {
      setState(() {
        _validationWarning = 'Private vehicle is required for non-shared groups.';
      });
    } else {
      setState(() {
        _privateVehicle = value;
        _validationWarning = null;
      });
    }
  }

  double _calculateTotal(Tour tour) {
    return _priceCalculator(
      tour: tour,
      adults: _adultsCount,
      children: _childrenCount,
      privateVehicle: _privateVehicle,
      groupSizeOptionLabel: _groupSizeOption,
    );
  }

  String _buildLiveSummaryString(Tour tour) {
    final List<String> parts = [];
    
    // Adults breakdown
    final String adultsStr = _adultsCount == 1 ? 'Adult' : 'Adults';
    parts.add('\$${tour.pricePerPerson.toInt()} x $_adultsCount $adultsStr');

    // Children breakdown
    if (_childrenCount > 0) {
      final String childrenStr = _childrenCount == 1 ? 'Child' : 'Children';
      final int childPrice = (tour.pricePerPerson * 0.5).toInt();
      parts.add('\$$childPrice x $_childrenCount $childrenStr');
    }

    // Options surcharge
    if (_privateVehicle) {
      parts.add('+ Private Vehicle');
    }

    return parts.join(' ');
  }

  Future<void> _submitBooking(Tour tour) async {
    setState(() {
      _validationWarning = null;
    });

    if (_selectedDate == null) {
      setState(() {
        _validationWarning = 'Please select a tour date before proceeding.';
      });
      return;
    }

    if (_pickupController.text.trim().isEmpty) {
      setState(() {
        _validationWarning = 'Please specify a pickup location.';
      });
      return;
    }

    final currentUser = ref.read(authServiceProvider).currentUser;
    if (currentUser == null) {
      setState(() {
        _validationWarning = 'You must be signed in to place a booking.';
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final docId = ref.read(bookingRepositoryProvider).generateNewBookingId();

      final total = _calculateTotal(tour);

      final booking = Booking(
        id: docId,
        userId: currentUser.uid,
        tourId: tour.id,
        tourSnapshot: TourSnapshot(
          title: tour.title,
          heroImageUrl: tour.heroImageUrl,
          destination: tour.destination,
        ),
        tourDate: _selectedDate!,
        adults: _adultsCount,
        children: _childrenCount,
        privateVehicle: _privateVehicle,
        groupSizeOption: _groupSizeOption,
        pickupLocation: _pickupController.text.trim(),
        specialRequests: _specialRequestsController.text.trim().isEmpty 
            ? null 
            : _specialRequestsController.text.trim(),
        totalPrice: total,
        currency: tour.currency,
        status: 'pending',
        createdAt: DateTime.now(),
      );

      final result = await ref.read(bookingRepositoryProvider).createPendingBooking(booking);

      await result.when(
        onSuccess: (_) {
          if (mounted) {
            unawaited(context.push('/booking/${booking.id}/checkout'));
          }
        },
        onFailure: (exception) {
          if (mounted) {
            setState(() {
              _validationWarning = 'Booking failed: ${exception.message}';
            });
          }
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _validationWarning = 'Booking failed: ${e.toString()}';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tourState = ref.watch(tourDetailsProvider(widget.tourId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          AppStrings.booking.title,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
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
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: AppColors.onSurface),
            onPressed: () => context.push('/search'),
          ),
        ],
      ),
      body: tourState.when(
        loading: () => const Center(child: LoadingIndicator()),
        error: (err, stack) => Center(
          child: ErrorStateView(
            message: err.toString(),
            onRetry: () => ref.refresh(tourDetailsProvider(widget.tourId)),
          ),
        ),
        data: (tour) {
          if (tour == null) {
            return const Center(child: Text('Tour not found.'));
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
                    // 1. Hero card
                    _buildHeroCard(tour),
                    AppSpacing.gapLg,

                    // 2. Select Date
                    const SectionHeader(
                      title: 'Select Tour Date',
                      icon: Icons.calendar_month,
                    ),
                    AppSpacing.gapSm,
                    _buildCalendarCard(tour),
                    AppSpacing.gapLg,

                    // 3. Participants
                    const SectionHeader(
                      title: 'Participants',
                      icon: Icons.people,
                    ),
                    AppSpacing.gapSm,
                    _buildParticipantsCard(tour),
                    AppSpacing.gapLg,

                    // 4. Private Options
                    const SectionHeader(
                      title: 'Private Options',
                      icon: Icons.shield,
                    ),
                    AppSpacing.gapSm,
                    _buildPrivateOptionsCard(),
                    AppSpacing.gapLg,

                    // 5. Logistics
                    const SectionHeader(
                      title: 'Logistics',
                      icon: Icons.location_on,
                    ),
                    AppSpacing.gapSm,
                    _buildLogisticsCard(),
                  ],
                ),
              ),

              // 6. Sticky bottom summary bar
              _buildStickyBottomSummary(tour),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeroCard(Tour tour) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadii.lg),
          image: DecorationImage(
            image: NetworkImage(tour.heroImageUrl),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            // Dark gradient scrim
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadii.lg),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.1),
                      Colors.black.withValues(alpha: 0.7),
                    ],
                    stops: const [0.5, 0.75, 1.0],
                  ),
                ),
              ),
            ),
            // Premium experience badge
            Positioned(
              top: AppSpacing.sm,
              left: AppSpacing.sm,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.circular(AppRadii.full),
                ),
                child: Text(
                  AppStrings.booking.premiumBadge,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                ),
              ),
            ),
            // Tour Title
            Positioned(
              bottom: AppSpacing.md,
              left: AppSpacing.md,
              right: AppSpacing.md,
              child: Text(
                tour.title,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarCard(Tour tour) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        boxShadow: AppShadows.level2,
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: _InlineCalendar(
        availableDates: tour.availableDates,
        selectedDate: _selectedDate,
        onDateSelected: (date) {
          setState(() {
            _selectedDate = date;
            _validationWarning = null;
          });
        },
      ),
    );
  }

  Widget _buildParticipantsCard(Tour tour) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        boxShadow: AppShadows.level2,
      ),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      child: Column(
        children: [
          _buildStepperRow(
            title: AppStrings.booking.adultsLabel,
            subtitle: AppStrings.booking.adultsSubtitle,
            value: _adultsCount,
            min: 1,
            max: tour.maxParticipants,
            onChanged: (val) {
              setState(() {
                _adultsCount = val;
              });
            },
          ),
          const Divider(height: 1.0, color: AppColors.outlineVariant),
          _buildStepperRow(
            title: AppStrings.booking.childrenLabel,
            subtitle: AppStrings.booking.childrenSubtitle,
            value: _childrenCount,
            min: 0,
            max: tour.maxParticipants - _adultsCount,
            onChanged: (val) {
              setState(() {
                _childrenCount = val;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStepperRow({
    required String title,
    required String subtitle,
    required int value,
    required int min,
    required int max,
    required ValueChanged<int> onChanged,
  }) {
    final canMinus = value > min;
    final canPlus = value < max;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.onSurface,
                    ),
              ),
              const SizedBox(height: 2.0),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
              ),
            ],
          ),
          Row(
            children: [
              GestureDetector(
                onTap: canMinus ? () => onChanged(value - 1) : null,
                child: Opacity(
                  opacity: canMinus ? 1.0 : 0.38,
                  child: Container(
                    width: 32.0,
                    height: 32.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primary, width: 1.5),
                    ),
                    child: const Center(
                      child: Icon(Icons.remove, size: 18.0, color: AppColors.primary),
                    ),
                  ),
                ),
              ),
              Container(
                width: 44.0,
                alignment: Alignment.center,
                child: Text(
                  '$value',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.onSurface,
                      ),
                ),
              ),
              GestureDetector(
                onTap: canPlus ? () => onChanged(value + 1) : null,
                child: Opacity(
                  opacity: canPlus ? 1.0 : 0.38,
                  child: Container(
                    width: 32.0,
                    height: 32.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primary, width: 1.5),
                    ),
                    child: const Center(
                      child: Icon(Icons.add, size: 18.0, color: AppColors.primary),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPrivateOptionsCard() {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  AppStrings.booking.privateVehicleLabel,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurface,
                      ),
                ),
              ),
              Switch(
                value: _privateVehicle,
                activeThumbColor: AppColors.primary,
                onChanged: _onPrivateVehicleToggled,
              ),
            ],
          ),
          AppSpacing.gapMd,
          Text(
            AppStrings.booking.groupSizeLimitLabel,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.onSurfaceVariant,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8.0),
          _buildSegmentedControl(),
        ],
      ),
    );
  }

  Widget _buildSegmentedControl() {
    final options = ['Shared', 'Max 6', 'Max 12'];
    return Container(
      padding: const EdgeInsets.all(4.0),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow, // light grey container background
        borderRadius: BorderRadius.circular(AppRadii.defaultRadius),
      ),
      child: Row(
        children: options.map((opt) {
          final isSelected = _groupSizeOption == opt;
          return Expanded(
            child: GestureDetector(
              onTap: () => _onGroupSizeSelected(opt),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppRadii.defaultRadius - 2),
                  boxShadow: isSelected
                      ? [ BoxShadow(color: AppColors.primaryContainer.withValues(alpha: 0.05),
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          )
                        ]
                      : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  opt,
                  style: TextStyle(
                    color: isSelected ? AppColors.primary : AppColors.onSurfaceVariant,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    fontSize: 14.0,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLogisticsCard() {
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
            controller: _pickupController,
            labelText: AppStrings.booking.pickupLocationLabel,
            hintText: AppStrings.booking.pickupLocationHint,
            prefixIcon: const Icon(Icons.hotel, size: 20.0),
            onChanged: (_) {
              if (_validationWarning != null) {
                setState(() {
                  _validationWarning = null;
                });
              }
            },
          ),
          AppSpacing.gapMd,
          AppTextField(
            controller: _specialRequestsController,
            labelText: AppStrings.booking.specialRequestsLabel,
            hintText: AppStrings.booking.specialRequestsHint,
            maxLines: 4,
            keyboardType: TextInputType.multiline,
            textInputAction: TextInputAction.newline,
          ),
        ],
      ),
    );
  }

  Widget _buildStickyBottomSummary(Tour tour) {
    final double total = _calculateTotal(tour);
    final String summaryText = _buildLiveSummaryString(tour);

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
              if (_validationWarning != null) ...[
                Text(
                  _validationWarning!,
                  style: const TextStyle(
                    color: AppColors.error,
                    fontWeight: FontWeight.w600,
                    fontSize: 13.0,
                  ),
                ),
                const SizedBox(height: 8.0),
              ],
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      summaryText,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  Row(
                    children: [
                      Text(
                        '${AppStrings.booking.totalLabel} ',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                      ),
                      Text(
                        '\$${total.toInt().toString().replaceAllMapped(
                              RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                              (Match m) => '${m[1]},',
                            )}',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
              AppSpacing.gapSm,
              PrimaryButton(
                label: AppStrings.booking.proceedButton,
                isLoading: _isSubmitting,
                onPressed: () => _submitBooking(tour),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Custom inline Month Calendar widget.
class _InlineCalendar extends StatefulWidget {
  final List<DateTime> availableDates;
  final DateTime? selectedDate;
  final ValueChanged<DateTime> onDateSelected;

  const _InlineCalendar({
    required this.availableDates,
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  State<_InlineCalendar> createState() => _InlineCalendarState();
}

class _InlineCalendarState extends State<_InlineCalendar> {
  late DateTime _currentMonth;

  static const List<String> _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  @override
  void initState() {
    super.initState();
    // Default to the first available date or current month
    if (widget.availableDates.isNotEmpty) {
      _currentMonth = DateTime(widget.availableDates.first.year, widget.availableDates.first.month, 1);
    } else {
      _currentMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);
    }
  }

  void _prevMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1, 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 1);
    });
  }

  bool _isAvailable(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    if (date.isBefore(today)) return false;

    for (final avail in widget.availableDates) {
      if (avail.year == date.year && avail.month == date.month && avail.day == date.day) {
        return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final monthName = _months[_currentMonth.month - 1];
    final year = _currentMonth.year;

    final firstDayOfMonth = DateTime(_currentMonth.year, _currentMonth.month, 1);
    final totalDays = DateTime(_currentMonth.year, _currentMonth.month + 1, 0).day;
    
    // Weekday is 1 (Monday) to 7 (Sunday). Empty slots = firstDayOfMonth.weekday - 1.
    final emptySlots = firstDayOfMonth.weekday - 1;
    final totalSlots = emptySlots + totalDays;
    final rowCount = (totalSlots / 7).ceil();

    return Column(
      children: [
        // Month Selector row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Semantics(
              label: 'Previous month',
              button: true,
              child: IconButton(
                tooltip: 'Previous month',
                icon: const Icon(Icons.chevron_left, color: AppColors.onSurface),
                onPressed: _prevMonth,
              ),
            ),
            Text(
              '$monthName $year',
              style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurface,
                  ),
            ),
            Semantics(
              label: 'Next month',
              button: true,
              child: IconButton(
                tooltip: 'Next month',
                icon: const Icon(Icons.chevron_right, color: AppColors.onSurface),
                onPressed: _nextMonth,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8.0),

        // Weekday header
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _WeekdayLabel('MO'),
            _WeekdayLabel('TU'),
            _WeekdayLabel('WE'),
            _WeekdayLabel('TH'),
            _WeekdayLabel('FR'),
            _WeekdayLabel('SA'),
            _WeekdayLabel('SU'),
          ],
        ),
        const SizedBox(height: 8.0),

        // Grid of dates
        Column(
          children: List.generate(rowCount, (rowIndex) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(7, (colIndex) {
                final cellIndex = rowIndex * 7 + colIndex;
                if (cellIndex < emptySlots || cellIndex >= totalSlots) {
                  return const Expanded(child: SizedBox(height: 40.0));
                }

                final dayNum = cellIndex - emptySlots + 1;
                final date = DateTime(_currentMonth.year, _currentMonth.month, dayNum);
                final isSelected = widget.selectedDate != null &&
                    widget.selectedDate!.year == date.year &&
                    widget.selectedDate!.month == date.month &&
                    widget.selectedDate!.day == date.day;
                final isAvail = _isAvailable(date);

                final now = DateTime.now();
                final isToday = date.year == now.year && date.month == now.month && date.day == now.day;

                return Expanded(
                  child: GestureDetector(
                    onTap: isAvail ? () => widget.onDateSelected(date) : null,
                    child: Container(
                      height: 40.0,
                      margin: const EdgeInsets.all(2.0),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : Colors.transparent,
                        shape: BoxShape.circle,
                        border: isToday && !isSelected
                            ? Border.all(color: AppColors.primary, width: 1.0)
                            : null,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '$dayNum',
                        style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: isSelected || isToday ? FontWeight.bold : FontWeight.normal,
                              color: isSelected
                                  ? Colors.white
                                  : isAvail
                                      ? AppColors.onSurface
                                      : AppColors.outlineVariant,
                            ),
                      ),
                    ),
                  ),
                );
              }),
            );
          }),
        ),
      ],
    );
  }
}

class _WeekdayLabel extends StatelessWidget {
  final String text;

  const _WeekdayLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Text(
          text,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.outline,
                fontWeight: FontWeight.bold,
              ),
        ),
      ),
    );
  }
}
