import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../core/services/auth_service.dart';
import '../../../booking/data/booking_repository.dart';
import '../../../search/data/search_repository.dart';

class TravelMapScreen extends ConsumerStatefulWidget {
  const TravelMapScreen({super.key});

  @override
  ConsumerState<TravelMapScreen> createState() => _TravelMapScreenState();
}

class _TravelMapScreenState extends ConsumerState<TravelMapScreen> {

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authServiceProvider).currentUser;
    if (user == null) {
      return const Scaffold(body: Center(child: Text('Please log in.')));
    }

    final bookingsState = ref.watch(userBookingsProvider(user.uid));
    final allToursState = ref.watch(searchResultsProvider(const SearchFilters()));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Travel Map',
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
      body: bookingsState.when(
        loading: () => const Center(child: LoadingIndicator()),
        error: (err, stack) => Center(child: Text('Error loading map: $err')),
        data: (bookings) {
          return allToursState.when(
            loading: () => const Center(child: LoadingIndicator()),
            error: (err, stack) => Center(child: Text('Error loading tours: $err')),
            data: (allTours) {
              // 1. Filter completed bookings
              final completed = bookings.where((b) {
                final isPast = b.tourDate.isBefore(DateTime.now().subtract(const Duration(days: 1)));
                return b.status == 'completed' || (b.status == 'confirmed' && isPast);
              }).toList();

              // 2. Generate markers from tour coordinates
              final Set<Marker> markers = {};
              LatLng initialCenter = const LatLng(20.0, 0.0); // Global center default

              for (var booking in completed) {
                try {
                  final tour = allTours.firstWhere((t) => t.id == booking.tourId);
                  final LatLng pos = LatLng(tour.latitude, tour.longitude);
                  initialCenter = pos; // Center on last found destination
                  markers.add(
                    Marker(
                      markerId: MarkerId(booking.id),
                      position: pos,
                      infoWindow: InfoWindow(
                        title: tour.title,
                        snippet: tour.destination,
                      ),
                    ),
                  );
                } catch (_) {
                  // Tour details not matching/found in current listings
                }
              }

              return GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: initialCenter,
                  zoom: markers.isEmpty ? 2.0 : 4.0,
                ),
                markers: markers,
                myLocationButtonEnabled: false,
              );
            },
          );
        },
      ),
    );
  }
}
