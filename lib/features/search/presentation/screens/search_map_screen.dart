import 'package:flutter/material.dart';
import '../../../../core/theme/app_radii.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../explore/domain/tour.dart';

/// Full screen Google Map overlay displaying matching query locations.
class SearchMapScreen extends StatefulWidget {
  final List<Tour> tours;

  const SearchMapScreen({super.key, required this.tours});

  @override
  State<SearchMapScreen> createState() => _SearchMapScreenState();
}

class _SearchMapScreenState extends State<SearchMapScreen> {

  void _showTourDetailBottomSheet(BuildContext context, Tour tour) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: AppColors.onSurface.withValues(alpha: 0.15),
      builder: (context) {
        final theme = Theme.of(context);
        return Container(
          margin: const EdgeInsets.all(AppSpacing.md),
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.0),
            boxShadow: [
              BoxShadow(
                color: AppColors.onSurface.withValues(alpha: 0.15),
                blurRadius: 10.0,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: AppRadii.borderMd,
                    child: Image.network(
                      tour.heroImageUrl,
                      width: 80.0,
                      height: 80.0,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tour.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4.0),
                        Text(
                          tour.destination,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4.0),
                        Text(
                          '${tour.currency} ${tour.pricePerPerson.toInt()} / person',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              AppSpacing.gapMd,
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                  const SizedBox(width: 8.0),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      context.push('/tour/${tour.id}');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: const RoundedRectangleBorder(
                        borderRadius: AppRadii.borderMd,
                      ),
                    ),
                    child: const Text('View Details'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    LatLng initialCenter = const LatLng(20.0, 0.0);
    if (widget.tours.isNotEmpty) {
      initialCenter = LatLng(widget.tours.first.latitude, widget.tours.first.longitude);
    }

    final Set<Marker> markers = widget.tours.map((tour) {
      return Marker(
        markerId: MarkerId(tour.id),
        position: LatLng(tour.latitude, tour.longitude),
        infoWindow: InfoWindow(
          title: tour.title,
          snippet: '${tour.currency} ${tour.pricePerPerson.toInt()}',
        ),
        onTap: () => _showTourDetailBottomSheet(context, tour),
      );
    }).toSet();

    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: initialCenter,
        zoom: widget.tours.length == 1 ? 8.0 : 2.0,
      ),
      markers: markers,
      onMapCreated: (controller) {},
    );
  }
}
