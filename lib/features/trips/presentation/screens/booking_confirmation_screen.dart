import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:url_launcher/url_launcher.dart';
import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../core/widgets/error_state_view.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/services/auth_service.dart';
import '../../../booking/booking.dart';
import '../../../tour_details/tour_details.dart';
import '../../../explore/domain/tour.dart';

class BookingConfirmationScreen extends ConsumerStatefulWidget {
  final String bookingId;

  const BookingConfirmationScreen({super.key, required this.bookingId});

  @override
  ConsumerState<BookingConfirmationScreen> createState() =>
      _BookingConfirmationScreenState();
}

class _BookingConfirmationScreenState
    extends ConsumerState<BookingConfirmationScreen> {
  LatLng? _mapCenter;
  bool _isGeocoding = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _initGeocoding(Booking booking, Tour tour) async {
    if (_mapCenter != null || _isGeocoding) return;
    setState(() {
      _isGeocoding = true;
    });

    try {
      final List<geo.Location> locations = await geo.locationFromAddress(
        booking.pickupLocation,
      );
      if (locations.isNotEmpty) {
        if (mounted) {
          setState(() {
            _mapCenter = LatLng(
              locations.first.latitude,
              locations.first.longitude,
            );
            _isGeocoding = false;
          });
        }
        return;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Geocoding failed, falling back to tour coordinates: $e');
      }
    }

    if (mounted) {
      setState(() {
        _mapCenter = LatLng(tour.latitude, tour.longitude);
        _isGeocoding = false;
      });
    }
  }

  Future<void> _openNativeMap(String address) async {
    final String query = Uri.encodeComponent(address);
    final String urlString = defaultTargetPlatform == TargetPlatform.iOS
        ? 'https://maps.apple.com/?q=$query'
        : 'https://www.google.com/maps/search/?api=1&query=$query';

    final Uri url = Uri.parse(urlString);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open map application.')),
        );
      }
    }
  }

  void _addToCalendar(Booking booking, Tour tour) {
    final Event event = Event(
      title: tour.title,
      description:
          'Booking Reference: ${booking.bookingReferenceCode ?? booking.id}\nPickup Location: ${booking.pickupLocation}',
      location: booking.pickupLocation,
      startDate: booking.tourDate,
      endDate: booking.tourDate.add(Duration(days: tour.durationDays)),
      allDay: true,
    );

    Add2Calendar.addEvent2Cal(event);
  }

  Future<void> _downloadPdfReceipt(Booking booking, Tour tour) async {
    final doc = pw.Document();

    final dateStr =
        '${booking.tourDate.day}/${booking.tourDate.month}/${booking.tourDate.year}';
    final guests = booking.adults + booking.children;

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(32.0),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header / Letterhead
                pw.Text(
                  'MVP Travel and Tourism LLC',
                  style: const pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Text(
                  'Luxury Expeditions & Custom Travel Services',
                  style: const pw.TextStyle(
                    fontSize: 10,
                    color: PdfColors.grey,
                  ),
                ),
                pw.SizedBox(height: 8.0),
                pw.Divider(thickness: 1.5),
                pw.SizedBox(height: 24.0),

                // Document Title
                pw.Center(
                  child: pw.Text(
                    'BOOKING RECEIPT',
                    style: const pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
                pw.SizedBox(height: 24.0),

                // Details
                _buildPdfRow(
                  'Booking Reference:',
                  booking.bookingReferenceCode ?? booking.id,
                ),
                _buildPdfRow('Tour:', tour.title),
                _buildPdfRow('Destination:', tour.destination),
                _buildPdfRow('Date:', dateStr),
                _buildPdfRow(
                  'Participants:',
                  '$guests ($guests Adults, 0 Children)',
                ),
                if (booking.privateVehicle)
                  _buildPdfRow(
                    'Transportation:',
                    'Private Vehicle Upgrade Included',
                  ),
                _buildPdfRow('Pickup Location:', booking.pickupLocation),
                pw.Divider(thickness: 0.5),
                pw.SizedBox(height: 12.0),
                _buildPdfRow(
                  'Total Price:',
                  '\$${booking.totalPrice.toInt().toString()} ${booking.currency.toUpperCase()}',
                  isBold: true,
                ),

                pw.Spacer(),
                pw.Divider(thickness: 0.5),
                pw.Center(
                  child: pw.Text(
                    'Thank you for booking with MVP Travel. For inquiries, email support@mvptravel.com.',
                    style: const pw.TextStyle(
                      fontSize: 9,
                      color: PdfColors.grey,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    await Printing.sharePdf(
      bytes: await doc.save(),
      filename: 'booking_receipt_${booking.bookingReferenceCode}.pdf',
    );
  }

  pw.Widget _buildPdfRow(String label, String value, {bool isBold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 6.0),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
          pw.Text(
            value,
            style: const pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bookingState = ref.watch(bookingDetailsProvider(widget.bookingId));
    final theme = Theme.of(context);
    final user = ref.watch(authServiceProvider).currentUser;

    return Scaffold(
      key: const Key('booking_confirmation_screen'),
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          AppStrings.common.appDisplayName,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
          onPressed: () => context.go('/explore'),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: () => context.go('/profile'),
              child: CircleAvatar(
                radius: 16.0,
                backgroundColor: AppColors.primaryContainer,
                backgroundImage: user?.photoUrl != null
                    ? NetworkImage(user!.photoUrl!)
                    : null,
                child: user?.photoUrl == null
                    ? const Icon(
                        Icons.person,
                        size: 18.0,
                        color: AppColors.primary,
                      )
                    : null,
              ),
            ),
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
            return const Center(child: Text('Booking not found.'));
          }

          final tourState = ref.watch(tourDetailsProvider(booking.tourId));

          return tourState.when(
            loading: () => const Center(child: LoadingIndicator()),
            error: (err, stack) =>
                Center(child: Text('Error loading tour: $err')),
            data: (tour) {
              if (tour == null) {
                return const Center(child: Text('Tour not found.'));
              }

              // Trigger geocoding process
              _initGeocoding(booking, tour);

              final dateStr =
                  '${booking.tourDate.day}/${booking.tourDate.month}/${booking.tourDate.year}';
              final guestsCount = booking.adults + booking.children;
              final guestsLabel = guestsCount == 1 ? 'Guest' : 'Guests';
              final step3Text =
                  '3 — Prepare for Adventure: Review the ${tour.category.toLowerCase()} preparation guide in your profile.';

              return SingleChildScrollView(
                padding: const EdgeInsets.only(
                  left: AppSpacing.containerMargin,
                  right: AppSpacing.containerMargin,
                  top: AppSpacing.sm,
                  bottom: 40.0,
                ),
                child: Column(
                  children: [
                    // Checked badge and headers
                    Container(
                      width: 64.0,
                      height: 64.0,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 32.0,
                        ),
                      ),
                    ),
                    AppSpacing.gapMd,
                    Text(
                      AppStrings.trips.confirmationTitle,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 6.0),
                    Text(
                      AppStrings.trips.confirmationSubtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    AppSpacing.gapLg,

                    // Tour Card
                    _buildConfirmedTourCard(
                      booking,
                      tour,
                      dateStr,
                      guestsCount,
                      guestsLabel,
                    ),
                    AppSpacing.gapLg,

                    // Logistics Section
                    _buildLogisticsSection(booking),
                    AppSpacing.gapLg,

                    // What's Next card
                    _buildWhatsNextCard(step3Text),
                    AppSpacing.gapLg,

                    // Action buttons
                    OutlinedButton(
                      onPressed: () => _addToCalendar(booking, tour),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.secondary,
                        side: const BorderSide(
                          color: AppColors.secondary,
                          width: 1.5,
                        ),
                        minimumSize: const Size(double.infinity, 50.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppRadii.defaultRadius,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.calendar_today, size: 18.0),
                          const SizedBox(width: 8.0),
                          Text(
                            AppStrings.trips.addToCalendarButton,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12.0),
                    OutlinedButton(
                      onPressed: () => _downloadPdfReceipt(booking, tour),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.onSurfaceVariant,
                        side: const BorderSide(
                          color: AppColors.outline,
                          width: 1.0,
                        ),
                        minimumSize: const Size(double.infinity, 50.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppRadii.defaultRadius,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.picture_as_pdf, size: 18.0),
                          const SizedBox(width: 8.0),
                          Text(
                            AppStrings.trips.downloadPdfReceiptButton,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    AppSpacing.gapLg,

                    // Back to Home
                    PrimaryButton(
                      buttonKey: const Key(
                        'booking_confirmation_back_home_button',
                      ),
                      label: AppStrings.trips.backToHomeButton,
                      onPressed: () => context.go('/explore'),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildConfirmedTourCard(
    Booking booking,
    Tour tour,
    String dateStr,
    int guestsCount,
    String guestsLabel,
  ) {
    final theme = Theme.of(context);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image block with overlay
          Stack(
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppRadii.md),
                    image: DecorationImage(
                      image: NetworkImage(tour.heroImageUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 12.0,
                left: 12.0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10.0,
                    vertical: 4.0,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(AppRadii.sm),
                  ),
                  child: Text(
                    AppStrings.trips.confirmedExperienceBadge,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 10.0,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
          AppSpacing.gapMd,
          Text(
            tour.title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.onSurface,
            ),
          ),
          AppSpacing.gapSm,

          // Details List
          _buildTourCardRow(Icons.calendar_today_outlined, dateStr),
          _buildTourCardRow(Icons.people_outline, '$guestsCount $guestsLabel'),
          if (booking.privateVehicle)
            _buildTourCardRow(
              Icons.airport_shuttle_outlined,
              'Private Vehicle Service',
            ),
          _buildTourCardRow(
            Icons.confirmation_number_outlined,
            booking.bookingReferenceCode ?? booking.id,
          ),
        ],
      ),
    );
  }

  Widget _buildTourCardRow(IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 16.0, color: AppColors.onSurfaceVariant),
          const SizedBox(width: 8.0),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogisticsSection(Booking booking) {
    final theme = Theme.of(context);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                color: AppColors.primary,
                size: 22.0,
              ),
              const SizedBox(width: 8.0),
              Text(
                AppStrings.trips.logisticsSection,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12.0),
          Text(
            AppStrings.trips.pickupLocationLabel,
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4.0),
          Text(
            booking.pickupLocation,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.onSurface,
            ),
          ),
          AppSpacing.gapMd,

          // Embedded Google Map (Interactive disabled)
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadii.md),
                border: Border.all(color: AppColors.outlineVariant, width: 1.0),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadii.md),
                child: _mapCenter == null
                    ? const Center(child: LoadingIndicator())
                    : GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: _mapCenter!,
                          zoom: 14.0,
                        ),
                        markers: {
                          Marker(
                            markerId: const MarkerId('pickup'),
                            position: _mapCenter!,
                          ),
                        },
                        zoomControlsEnabled: false,
                        scrollGesturesEnabled: false,
                        zoomGesturesEnabled: false,
                        rotateGesturesEnabled: false,
                        tiltGesturesEnabled: false,
                        myLocationButtonEnabled: false,
                      ),
              ),
            ),
          ),
          AppSpacing.gapMd,

          // View in Maps pill
          Center(
            child: OutlinedButton(
              onPressed: () => _openNativeMap(booking.pickupLocation),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.outline, width: 1.0),
                shape: const StadiumBorder(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 8.0,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.map,
                    size: 16.0,
                    color: AppColors.onSurfaceVariant,
                  ),
                  const SizedBox(width: 6.0),
                  Text(
                    AppStrings.trips.viewInMapsButton,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: AppColors.onSurfaceVariant,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWhatsNextCard(String step3Text) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.primary, // Dark navy
        borderRadius: BorderRadius.circular(AppRadii.defaultRadius),
        boxShadow: AppShadows.level2,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.trips.whatsNextHeader,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          AppSpacing.gapMd,
          _buildWhatsNextStep(AppStrings.trips.whatsNextStep1),
          _buildWhatsNextStep(AppStrings.trips.whatsNextStep2),
          _buildWhatsNextStep(step3Text),
        ],
      ),
    );
  }

  Widget _buildWhatsNextStep(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 13.0,
          height: 1.4,
        ),
      ),
    );
  }
}
