import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../core/widgets/error_state_view.dart';
import '../../../../core/widgets/rating_stars.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/storage_service.dart';
import '../../../booking/booking.dart';
import '../../data/reviews_repository.dart';
import '../../domain/usecases/submit_review_use_case.dart';

class PendingImage {
  final XFile file;
  final String tempId;
  final Uint8List bytes;
  PendingImage({required this.file, required this.tempId, required this.bytes});
}

class ReviewTripScreen extends ConsumerStatefulWidget {
  final String bookingId;

  const ReviewTripScreen({super.key, required this.bookingId});

  @override
  ConsumerState<ReviewTripScreen> createState() => _ReviewTripScreenState();
}

class _ReviewTripScreenState extends ConsumerState<ReviewTripScreen> {
  final _commentController = TextEditingController();
  final _picker = ImagePicker();
  double _overallRating = 0.0;
  final Map<String, double> _aspectRatings = {
    'Service': 0.0,
    'Accommodation': 0.0,
    'Activities': 0.0,
    'Value': 0.0,
  };
  String? _expandedAspect;

  final List<String> _uploadedImageUrls = [];
  final List<PendingImage> _pendingImages = [];
  final Map<String, double> _uploadProgress = {};
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _uploadPhoto() async {
    final int totalCount = _uploadedImageUrls.length + _pendingImages.length;
    if (totalCount >= 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You can upload up to 6 photos only.')),
      );
      return;
    }

    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1600,
      maxHeight: 1600,
      imageQuality: 85,
    );
    if (pickedFile == null) return;

    final tempId = DateTime.now().millisecondsSinceEpoch.toString();
    final pending = PendingImage(
      file: pickedFile,
      tempId: tempId,
      bytes: await pickedFile.readAsBytes(),
    );

    setState(() {
      _pendingImages.add(pending);
      _uploadProgress[tempId] = 0.1; // Initial progress
    });

    try {
      final storage = ref.read(storageServiceProvider);
      // Simulate progress updates for a smoother visual feedback loop
      for (double p = 0.2; p < 0.9; p += 0.2) {
        await Future.delayed(const Duration(milliseconds: 150));
        if (mounted) {
          setState(() {
            _uploadProgress[tempId] = p;
          });
        }
      }

      final user = ref.read(authServiceProvider).currentUser;
      final String path = 'reviews/${user?.uid ?? 'guest'}/$tempId.png';
      final String url = await storage.uploadImage(pickedFile, path);

      if (mounted) {
        setState(() {
          _uploadedImageUrls.add(url);
          _pendingImages.remove(pending);
          _uploadProgress.remove(tempId);
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _pendingImages.remove(pending);
          _uploadProgress.remove(tempId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: ${e.toString()}')),
        );
      }
    }
  }

  void _removePhoto(int index) {
    setState(() {
      _uploadedImageUrls.removeAt(index);
    });
  }

  Future<void> _submitReview(Booking booking) async {
    if (_overallRating == 0.0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an overall rating before submitting.'),
        ),
      );
      return;
    }

    final user = ref.read(authServiceProvider).currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please sign in before submitting a review.'),
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final String name = user.displayName ?? 'Valued Guest';
      final useCase = SubmitReviewUseCase(ref.read(reviewsRepositoryProvider));

      final res = await useCase.execute(
        userId: user.uid,
        userName: name,
        userPhotoUrl: user.photoUrl ?? '',
        bookingId: booking.id,
        tourId: booking.tourId,
        overallRating: _overallRating,
        aspectRatings: _aspectRatings,
        comment: _commentController.text.trim(),
        photoUrls: _uploadedImageUrls,
      );

      res.when(
        onSuccess: (_) {
          if (mounted) {
            context.go(
              '/trips/${booking.id}/review/success',
              extra: {
                'tourTitle': booking.tourSnapshot.title,
                'tourHeroImageUrl': booking.tourSnapshot.heroImageUrl,
                'hasUploadedPhotos': _uploadedImageUrls.isNotEmpty,
              },
            );
          }
        },
        onFailure: (exception) {
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(exception.message)));
          }
        },
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit review: ${e.toString()}')),
        );
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
    final bookingState = ref.watch(bookingDetailsProvider(widget.bookingId));
    final theme = Theme.of(context);

    return Scaffold(
      key: const Key('review_trip_screen'),
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Review Trip',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
          onPressed: () => context.pop(),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: AppColors.onSurface),
            onSelected: (value) {
              if (value == 'cancel') {
                context.pop();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'cancel',
                child: Text(
                  'Cancel Review',
                  style: TextStyle(color: AppColors.error),
                ),
              ),
            ],
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
          final String startDateStr =
              '${booking.tourDate.day}/${booking.tourDate.month}/${booking.tourDate.year}';

          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.only(
                  left: AppSpacing.containerMargin,
                  right: AppSpacing.containerMargin,
                  top: AppSpacing.sm,
                  bottom: 100.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Booking Summary Card
                    AppCard(
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(AppRadii.md),
                            child: Image.network(
                              booking.tourSnapshot.heroImageUrl,
                              width: 80.0,
                              height: 80.0,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 16.0),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  booking.tourSnapshot.title,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.onSurface,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4.0),
                                Text(
                                  startDateStr,
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    AppSpacing.gapLg,

                    // How was your experience?
                    Center(
                      child: Column(
                        children: [
                          Text(
                            'How was your experience?',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.onSurface,
                            ),
                          ),
                          const SizedBox(height: 12.0),
                          RatingStars(
                            rating: _overallRating,
                            starSize: 36.0,
                            interactiveKeyPrefix: 'review_star',
                            onRatingChanged: (val) {
                              setState(() {
                                _overallRating = val;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    AppSpacing.gapLg,

                    // Rate Specific Aspects
                    _buildAspectsSection(context),
                    AppSpacing.gapLg,

                    // Share your thoughts
                    Text(
                      'Share your thoughts',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    AppTextField(
                      controller: _commentController,
                      labelText: 'Comments',
                      hintText: 'Tell us about your highlight moments...',
                      maxLines: 5,
                      maxLength: 1000,
                    ),
                    AppSpacing.gapLg,

                    // Share your memories (up to 6 photos)
                    _buildMemoriesSection(context),
                  ],
                ),
              ),

              // Sticky Bottom Submit Button
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.containerMargin),
                  decoration: const BoxDecoration(
                    color: AppColors.background,
                    border: Border(
                      top: BorderSide(
                        color: AppColors.outlineVariant,
                        width: 1.0,
                      ),
                    ),
                  ),
                  child: PrimaryButton(
                    buttonKey: const Key('review_submit_button'),
                    label: 'Submit Review →',
                    onPressed: (_overallRating == 0.0 || _isSubmitting)
                        ? null
                        : () => _submitReview(booking),
                  ),
                ),
              ),

              if (_isSubmitting)
                Container(
                  color: AppColors.onSurface.withValues(alpha: 0.26),
                  child: const Center(child: LoadingIndicator()),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAspectsSection(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'RATE SPECIFIC ASPECTS',
          style: theme.textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.onSurfaceVariant,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 12.0),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.3,
          crossAxisSpacing: 12.0,
          mainAxisSpacing: 12.0,
          children: _aspectRatings.keys.map((aspect) {
            final double rating = _aspectRatings[aspect]!;
            final bool isExpanded = _expandedAspect == aspect;

            IconData iconData = Icons.star_outline;
            if (aspect == 'Service') iconData = Icons.room_service_outlined;
            if (aspect == 'Accommodation') iconData = Icons.hotel_outlined;
            if (aspect == 'Activities') iconData = Icons.pool_outlined;
            if (aspect == 'Value') iconData = Icons.attach_money_outlined;

            return GestureDetector(
              onTap: () {
                setState(() {
                  _expandedAspect = isExpanded ? null : aspect;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: isExpanded ? AppColors.primaryContainer : Colors.white,
                  borderRadius: BorderRadius.circular(AppRadii.defaultRadius),
                  border: Border.all(
                    color: isExpanded
                        ? AppColors.primary
                        : AppColors.outlineVariant,
                    width: 1.0,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          iconData,
                          color: isExpanded
                              ? AppColors.primary
                              : AppColors.onSurfaceVariant,
                        ),
                        const SizedBox(width: 8.0),
                        Expanded(
                          child: Text(
                            aspect,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8.0),
                    if (isExpanded)
                      RatingStars(
                        rating: rating,
                        starSize: 22.0,
                        onRatingChanged: (val) {
                          setState(() {
                            _aspectRatings[aspect] = val;
                          });
                        },
                      )
                    else
                      Row(
                        children: [
                          RatingStars(rating: rating, starSize: 14.0),
                          const SizedBox(width: 4.0),
                          Text(
                            rating > 0 ? rating.toInt().toString() : '--',
                            style: const TextStyle(
                              fontSize: 11.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildMemoriesSection(BuildContext context) {
    final theme = Theme.of(context);
    final int uploadedCount = _uploadedImageUrls.length;
    final int pendingCount = _pendingImages.length;
    final bool showUploadButton = (uploadedCount + pendingCount) < 6;
    final int totalItems =
        uploadedCount + pendingCount + (showUploadButton ? 1 : 0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Share your memories',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.onSurface,
              ),
            ),
            Text(
              'Up to 6 photos',
              style: theme.textTheme.labelSmall?.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12.0),
        SizedBox(
          height: 80.0,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: totalItems,
            itemBuilder: (context, index) {
              if (index < uploadedCount) {
                final url = _uploadedImageUrls[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadii.md),
                        child: Image.network(
                          url,
                          width: 80.0,
                          height: 80.0,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 4.0,
                        right: 4.0,
                        child: GestureDetector(
                          onTap: () => _removePhoto(index),
                          child: CircleAvatar(
                            radius: 10.0,
                            backgroundColor: AppColors.onSurface.withValues(
                              alpha: 0.54,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 12.0,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              } else if (index < uploadedCount + pendingCount) {
                final pending = _pendingImages[index - uploadedCount];
                final progress = _uploadProgress[pending.tempId] ?? 0.0;
                return Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadii.md),
                        child: Opacity(
                          opacity: 0.5,
                          child: Image.memory(
                            pending.bytes,
                            width: 80.0,
                            height: 80.0,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned.fill(
                        child: Center(
                          child: SizedBox(
                            width: 24.0,
                            height: 24.0,
                            child: CircularProgressIndicator(
                              value: progress,
                              strokeWidth: 2.5,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              } else {
                return GestureDetector(
                  onTap: _uploadPhoto,
                  child: Container(
                    width: 80.0,
                    height: 80.0,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(AppRadii.md),
                      border: Border.all(
                        color: AppColors.outline,
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_a_photo_outlined,
                          color: AppColors.primary,
                        ),
                        SizedBox(height: 4.0),
                        Text(
                          'Upload',
                          style: TextStyle(
                            fontSize: 10.0,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
            },
          ),
        ),
      ],
    );
  }
}
