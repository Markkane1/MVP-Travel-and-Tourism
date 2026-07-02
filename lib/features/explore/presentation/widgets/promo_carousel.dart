import 'dart:async';
import '../../../../core/theme/app_radii.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/tour.dart';

/// Auto-advancing carousel displaying featured promotion hero cards.
class PromoCarousel extends StatefulWidget {
  final List<Tour> promotions;

  const PromoCarousel({super.key, required this.promotions});

  @override
  State<PromoCarousel> createState() => _PromoCarouselState();
}

class _PromoCarouselState extends State<PromoCarousel> {
  late final PageController _pageController;
  int _currentIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!mounted || widget.promotions.isEmpty) return;
      final nextIndex = (_currentIndex + 1) % widget.promotions.length;
      _pageController.animateToPage(
        nextIndex,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.promotions.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Listener(
          onPointerDown: (_) => _timer?.cancel(),
          onPointerUp: (_) => _startTimer(),
          child: SizedBox(
            height: 200.0,
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemCount: widget.promotions.length,
              itemBuilder: (context, index) {
                final tour = widget.promotions[index];
                return GestureDetector(
                  onTap: () => context.push('/tour/${tour.id}'),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                    decoration: BoxDecoration(
                      borderRadius: AppRadii.borderLg,
                      image: DecorationImage(
                        image: NetworkImage(tour.heroImageUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Stack(
                      children: [
                        // Scrim gradient overlay for text readability
                        Positioned.fill(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              borderRadius: AppRadii.borderLg,
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withValues(alpha: 0.1),
                                  Colors.black.withValues(alpha: 0.7),
                                ],
                                stops: const [0.0, 0.4, 1.0],
                              ),
                            ),
                          ),
                        ),
                        // Promo Content Text
                        Positioned(
                          left: AppSpacing.lg,
                          bottom: AppSpacing.lg,
                          right: AppSpacing.lg,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'LIMITED OFFER',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: AppColors.secondary,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.0,
                                ),
                              ),
                              const SizedBox(height: 4.0),
                              Text(
                                tour.title == 'Overwater Villa Experience'
                                    ? 'Escape to Paradise'
                                    : tour.title,
                                style: theme.textTheme.titleLarge?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22.0,
                                ),
                              ),
                              const SizedBox(height: 4.0),
                              Text(
                                tour.title == 'Overwater Villa Experience'
                                    ? 'Up to 40% off on overwater villas.'
                                    : 'Explore luxury travel destinations now.',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.9),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        AppSpacing.gapMd,
        // Dot indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.promotions.length,
            (index) => Container(
              width: 8.0,
              height: 8.0,
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _currentIndex == index
                    ? AppColors.primary
                    : AppColors.outlineVariant,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
