import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../core/services/auth_service.dart';
import '../../data/profile_repository.dart';

class TravelPreferencesScreen extends ConsumerStatefulWidget {
  const TravelPreferencesScreen({super.key});

  @override
  ConsumerState<TravelPreferencesScreen> createState() => _TravelPreferencesScreenState();
}

class _TravelPreferencesScreenState extends ConsumerState<TravelPreferencesScreen> {
  final _dietaryController = TextEditingController();
  String _seatPreference = 'Any';
  String _hotelClassPreference = 'Luxury';
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // Load initial values from Firestore
    final profileState = ref.read(userFirestoreDataProvider).value;
    if (profileState != null && profileState['preferences'] is Map) {
      final prefs = profileState['preferences'] as Map;
      _dietaryController.text = prefs['dietary'] ?? '';
      _seatPreference = prefs['seat'] ?? 'Any';
      _hotelClassPreference = prefs['hotelClass'] ?? 'Luxury';
    }
  }

  @override
  void dispose() {
    _dietaryController.dispose();
    super.dispose();
  }

  Future<void> _savePreferences(String uid) async {
    setState(() {
      _isSaving = true;
    });

    try {
      await ref.read(profileRepositoryProvider).saveTravelPreferences(
            uid: uid,
            dietary: _dietaryController.text.trim(),
            seat: _seatPreference,
            hotelClass: _hotelClassPreference,
          );

      if (mounted) {
        ref.invalidate(userFirestoreDataProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Preferences saved successfully.')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save preferences: ${e.toString()}')),
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
    final user = ref.watch(authServiceProvider).currentUser;
    if (user == null) {
      return const Scaffold(body: Center(child: Text('Please log in.')));
    }

    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Travel Preferences',
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
      body: _isSaving
          ? const Center(child: LoadingIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.containerMargin),
              child: Column(
                children: [
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Configure Preferences',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.onSurface,
                          ),
                        ),
                        const SizedBox(height: 16.0),

                        // Dietary
                        AppTextField(
                          controller: _dietaryController,
                          labelText: 'Dietary Requirements',
                          hintText: 'e.g. Vegetarian, Gluten-free, none',
                        ),
                        AppSpacing.gapMd,

                        // Seat Preferences dropdown
                        DropdownButtonFormField<String>(
                          // ignore: deprecated_member_use
                          value: _seatPreference,
                          decoration: const InputDecoration(
                            labelText: 'Seating Preference',
                            border: OutlineInputBorder(),
                          ),
                          items: ['Any', 'Window', 'Aisle'].map((seat) {
                            return DropdownMenuItem<String>(
                              value: seat,
                              child: Text(seat),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                _seatPreference = val;
                              });
                            }
                          },
                        ),
                        AppSpacing.gapMd,

                        // Hotel Class dropdown
                        DropdownButtonFormField<String>(
                          // ignore: deprecated_member_use
                          value: _hotelClassPreference,
                          decoration: const InputDecoration(
                            labelText: 'Preferred Hotel Class',
                            border: OutlineInputBorder(),
                          ),
                          items: ['Luxury', 'Premium', 'Standard'].map((hotel) {
                            return DropdownMenuItem<String>(
                              value: hotel,
                              child: Text(hotel),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                _hotelClassPreference = val;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  AppSpacing.gapLg,

                  PrimaryButton(
                    label: 'Save Preferences',
                    onPressed: () => _savePreferences(user.uid),
                  ),
                ],
              ),
            ),
    );
  }
}
