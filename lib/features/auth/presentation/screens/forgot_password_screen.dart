import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/constants/app_strings.dart';
import '../controllers/auth_controller.dart';

/// Password recovery screen for submitting a reset link request.
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _isSuccess = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await ref
        .read(authControllerProvider.notifier)
        .sendPasswordReset(_emailController.text.trim());

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      result.when(
        onSuccess: (_) {
          setState(() {
            _isSuccess = true;
          });
        },
        onFailure: (exception) {
          setState(() {
            _errorMessage = exception.message;
          });
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset Password'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                AppStrings.common.appDisplayName,
                style: textTheme.displayLarge?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              AppSpacing.gapLg,
              AppCard(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _isSuccess
                      ? Column(
                          key: const ValueKey('success-state'),
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.check_circle_outline,
                              color: Colors.green,
                              size: 64.0,
                            ),
                            AppSpacing.gapMd,
                            Text(
                              'Email Dispatched',
                              style: textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            AppSpacing.gapBase,
                            Text(
                              'A password reset link has been sent to ${_emailController.text.trim()}. Please check your spam folder if you do not see it shortly.',
                              textAlign: TextAlign.center,
                              style: textTheme.bodyMedium,
                            ),
                            AppSpacing.gapLg,
                            PrimaryButton(
                              label: 'Back to Sign In',
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                          ],
                        )
                      : Form(
                          key: _formKey,
                          child: Column(
                            key: const ValueKey('form-state'),
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Recover Account',
                                style: textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              AppSpacing.gapBase,
                              Text(
                                'Enter your email address below, and we will send you a secure link to reset your account password.',
                                style: textTheme.bodyMedium?.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                              AppSpacing.gapLg,
                              if (_errorMessage != null) ...[
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(AppSpacing.base),
                                  margin: const EdgeInsets.only(bottom: AppSpacing.md),
                                  decoration: BoxDecoration(
                                    color: AppColors.errorContainer,
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  child: Text(
                                    _errorMessage!,
                                    style: textTheme.bodyMedium?.copyWith(
                                      color: AppColors.onErrorContainer,
                                    ),
                                  ),
                                ),
                              ],
                              AppTextField(
                                controller: _emailController,
                                labelText: AppStrings.auth.emailLabel,
                                hintText: 'email@example.com',
                                prefixIcon: const Icon(Icons.mail_outline),
                                keyboardType: TextInputType.emailAddress,
                                validator: Validators.validateEmail,
                              ),
                              AppSpacing.gapLg,
                              PrimaryButton(
                                label: AppStrings.auth.sendResetLinkButton,
                                onPressed: _isLoading ? null : _submit,
                                isLoading: _isLoading,
                              ),
                            ],
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
