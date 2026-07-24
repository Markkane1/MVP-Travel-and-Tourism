import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/route_paths.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../auth/auth.dart';

class SecurityPrivacyScreen extends ConsumerStatefulWidget {
  const SecurityPrivacyScreen({super.key});

  @override
  ConsumerState<SecurityPrivacyScreen> createState() =>
      _SecurityPrivacyScreenState();
}

class _SecurityPrivacyScreenState extends ConsumerState<SecurityPrivacyScreen> {
  bool _isProcessing = false;

  Future<void> _sendPasswordReset() async {
    final user = ref.read(authServiceProvider).currentUser;
    if (user == null) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      final res = await ref
          .read(authControllerProvider.notifier)
          .sendPasswordReset(user.email);
      res.when(
        onSuccess: (_) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Password reset link sent to your email.'),
              ),
            );
          }
        },
        onFailure: (exception) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Failed to send reset link: ${exception.message}',
                ),
              ),
            );
          }
        },
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<void> _deleteAccount() async {
    // Show confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(AppStrings.profile.deleteAccountTitle),
          content: Text(AppStrings.profile.deleteAccountBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text(
                'Cancel',
                style: TextStyle(color: AppColors.onSurfaceVariant),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(
                AppStrings.profile.deleteConfirmButton,
                style: const TextStyle(
                  color: AppColors.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      final auth = ref.read(authServiceProvider);
      final deleteResult = await auth.deleteUserAccount();

      await deleteResult.when(
        onSuccess: (_) async {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Account permanently deleted.')),
            );
            context.go(RoutePaths.auth);
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
          SnackBar(content: Text('Deletion failed: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Security & Privacy',
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
      body: _isProcessing
          ? const Center(child: LoadingIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.containerMargin),
              child: Column(
                children: [
                  // Change Password card
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Update Credentials',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          'If you want to update your sign in password, tap below to request a secure reset link.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 16.0),
                        OutlinedButton(
                          onPressed: _isProcessing ? null : _sendPasswordReset,
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 50.0),
                            side: const BorderSide(color: AppColors.primary),
                          ),
                          child: const Text(
                            'Request Password Reset',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                  AppSpacing.gapLg,

                  // Delete Account Card
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Danger Zone',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.error,
                            fontSize: 16.0,
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          'Permanently delete your MVP Travel account and erase all saved credentials, wishlist destinations, and booking configurations.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 16.0),
                        ElevatedButton(
                          onPressed: _isProcessing ? null : _deleteAccount,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.error,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 50.0),
                          ),
                          child: const Text(
                            'Delete Account Permanently',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
