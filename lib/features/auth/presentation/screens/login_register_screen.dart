import 'package:flutter/gestures.dart';
import '../../../../core/theme/app_radii.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/routing/route_paths.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/secondary_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/constants/app_strings.dart';
import '../controllers/auth_controller.dart';

/// The consolidated Authentication screen featuring Login & Register tabs.
class LoginRegisterScreen extends ConsumerStatefulWidget {
  const LoginRegisterScreen({super.key});

  @override
  ConsumerState<LoginRegisterScreen> createState() =>
      _LoginRegisterScreenState();
}

class _LoginRegisterScreenState extends ConsumerState<LoginRegisterScreen> {
  final _loginFormKey = GlobalKey<FormState>();
  final _registerFormKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLogin = true;
  bool _isLoading = false;
  bool _agreedToTerms = false;
  String? _errorMessage;
  String? _termsCheckboxError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleEmailAuth() async {
    setState(() {
      _errorMessage = null;
      _termsCheckboxError = null;
    });

    if (_isLogin) {
      if (!_loginFormKey.currentState!.validate()) return;

      setState(() => _isLoading = true);
      final result = await ref
          .read(authControllerProvider.notifier)
          .login(_emailController.text.trim(), _passwordController.text);

      if (mounted) {
        setState(() => _isLoading = false);
        result.when(
          onSuccess: (_) => context.go(RoutePaths.explore),
          onFailure: (exception) =>
              setState(() => _errorMessage = exception.message),
        );
      }
    } else {
      if (!_registerFormKey.currentState!.validate()) return;
      if (!_agreedToTerms) {
        setState(
          () => _termsCheckboxError =
              'You must agree to the Terms & Privacy Policy.',
        );
        return;
      }

      setState(() => _isLoading = true);
      final result = await ref
          .read(authControllerProvider.notifier)
          .register(
            _nameController.text.trim(),
            _emailController.text.trim(),
            _passwordController.text,
          );

      if (mounted) {
        setState(() => _isLoading = false);
        result.when(
          onSuccess: (_) => context.go(RoutePaths.explore),
          onFailure: (exception) =>
              setState(() => _errorMessage = exception.message),
        );
      }
    }
  }

  Future<void> _handleSocialAuth(bool isGoogle) async {
    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });

    final notifier = ref.read(authControllerProvider.notifier);
    final result = isGoogle
        ? await notifier.loginWithGoogle()
        : await notifier.loginWithApple();

    if (mounted) {
      setState(() => _isLoading = false);
      result.when(
        onSuccess: (_) => context.go(RoutePaths.explore),
        onFailure: (exception) =>
            setState(() => _errorMessage = exception.message),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authControllerProvider, (_, next) {
      next.whenData((user) {
        if (user != null && mounted) {
          context.go(RoutePaths.explore);
        }
      });
    });

    final theme = Theme.of(context);

    return Scaffold(
      key: const Key('auth_screen'),
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            // Close dismiss button top-left
            Positioned(
              top: AppSpacing.sm,
              left: AppSpacing.sm,
              child: IconButton(
                icon: const Icon(
                  Icons.close,
                  color: AppColors.onSurface,
                  size: 24.0,
                ),
                onPressed: () {
                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  } else {
                    context.go(RoutePaths.explore);
                  }
                },
              ),
            ),
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 48.0),
                    SizedBox(
                      width: 280.0,
                      child: Image.asset(
                        'assets/icons/app_logo_full.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                    AppSpacing.gapLg,

                    // Main Form Card
                    AppCard(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Segmented Selector Header with bottom border divider
                          Container(
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: AppColors.outlineVariant,
                                  width: 1.0,
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    key: const Key('auth_toggle_sign_in'),
                                    onTap: _isLoading
                                        ? null
                                        : () => setState(() {
                                            _isLogin = true;
                                            _errorMessage = null;
                                          }),
                                    child: Column(
                                      children: [
                                        Text(
                                          AppStrings.auth.signInButton,
                                          style: theme.textTheme.titleMedium
                                              ?.copyWith(
                                                fontWeight: _isLogin
                                                    ? FontWeight.bold
                                                    : FontWeight.w500,
                                                color: _isLogin
                                                    ? AppColors.primary
                                                    : AppColors.outline,
                                              ),
                                        ),
                                        AppSpacing.gapBase,
                                        Container(
                                          height: 3.0,
                                          color: _isLogin
                                              ? AppColors.primary
                                              : Colors.transparent,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: GestureDetector(
                                    key: const Key('auth_toggle_register'),
                                    onTap: _isLoading
                                        ? null
                                        : () => setState(() {
                                            _isLogin = false;
                                            _errorMessage = null;
                                          }),
                                    child: Column(
                                      children: [
                                        Text(
                                          'Register',
                                          style: theme.textTheme.titleMedium
                                              ?.copyWith(
                                                fontWeight: !_isLogin
                                                    ? FontWeight.bold
                                                    : FontWeight.w500,
                                                color: !_isLogin
                                                    ? AppColors.primary
                                                    : AppColors.outline,
                                              ),
                                        ),
                                        AppSpacing.gapBase,
                                        Container(
                                          height: 3.0,
                                          color: !_isLogin
                                              ? AppColors.primary
                                              : Colors.transparent,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          AppSpacing.gapLg,

                          // Error feedback block
                          if (_errorMessage != null) ...[
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(AppSpacing.base),
                              margin: const EdgeInsets.only(
                                bottom: AppSpacing.md,
                              ),
                              decoration: const BoxDecoration(
                                color: AppColors.errorContainer,
                                borderRadius: AppRadii.borderDefault,
                              ),
                              child: Text(
                                _errorMessage!,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: AppColors.onErrorContainer,
                                ),
                              ),
                            ),
                          ],

                          // Form Body
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 250),
                            child: _isLogin
                                ? _buildLoginForm()
                                : _buildRegisterForm(),
                          ),
                          AppSpacing.gapLg,

                          // Divider section
                          Row(
                            children: [
                              const Expanded(child: Divider()),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                ),
                                child: Text(
                                  AppStrings.auth.orContinueWith,
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: AppColors.outline,
                                  ),
                                ),
                              ),
                              const Expanded(child: Divider()),
                            ],
                          ),
                          AppSpacing.gapLg,

                          // Social Actions
                          Row(
                            children: [
                              Expanded(
                                child: SecondaryButton(
                                  label: AppStrings.auth.googleButton,
                                  onPressed: _isLoading
                                      ? null
                                      : () => _handleSocialAuth(true),
                                  icon: const Icon(
                                    Icons.g_mobiledata,
                                    size: 28.0,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12.0),
                              Expanded(
                                child: SecondaryButton(
                                  label: AppStrings.auth.appleButton,
                                  onPressed: _isLoading
                                      ? null
                                      : () => _handleSocialAuth(false),
                                  icon: const Icon(Icons.apple, size: 24.0),
                                ),
                              ),
                            ],
                          ),
                          AppSpacing.gapLg,

                          // Interactive legal footnote
                          RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: AppColors.onSurfaceVariant,
                              ),
                              children: [
                                TextSpan(text: AppStrings.auth.footnotePrefix),
                                TextSpan(
                                  text: AppStrings.auth.termsOfUseLink,
                                  style: const TextStyle(
                                    color: AppColors.secondary,
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.underline,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () =>
                                        context.push('/legal/terms'),
                                ),
                                TextSpan(text: AppStrings.auth.footnoteAnd),
                                TextSpan(
                                  text: AppStrings.auth.privacyStandardsLink,
                                  style: const TextStyle(
                                    color: AppColors.secondary,
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.underline,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () =>
                                        context.push('/legal/privacy'),
                                ),
                                TextSpan(text: AppStrings.auth.footnoteSuffix),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    final theme = Theme.of(context);
    return Form(
      key: _loginFormKey,
      child: Column(
        key: const ValueKey('login-fields'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppTextField(
            fieldKey: const Key('auth_email_field'),
            controller: _emailController,
            labelText: AppStrings.auth.emailLabel,
            hintText: 'email@example.com',
            prefixIcon: const Icon(Icons.mail_outline),
            keyboardType: TextInputType.emailAddress,
            validator: Validators.validateEmail,
            enabled: !_isLoading,
          ),
          AppSpacing.gapMd,
          AppTextField(
            fieldKey: const Key('auth_password_field'),
            controller: _passwordController,
            labelText: AppStrings.auth.passwordLabel,
            hintText: 'Enter password',
            prefixIcon: const Icon(Icons.lock_outline),
            isPassword: true,
            validator: (val) => Validators.validateRequired(val, 'Password'),
            enabled: !_isLoading,
          ),
          AppSpacing.gapBase,
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: _isLoading
                  ? null
                  : () => context.push('/auth/forgot-password'),
              child: Text(
                AppStrings.auth.forgotPasswordButton,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: AppColors.secondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          AppSpacing.gapMd,
          PrimaryButton(
            buttonKey: const Key('auth_submit_button'),
            label: AppStrings.auth.signInButton,
            onPressed: _isLoading ? null : _handleEmailAuth,
            isLoading: _isLoading,
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterForm() {
    final theme = Theme.of(context);
    return Form(
      key: _registerFormKey,
      child: Column(
        key: const ValueKey('register-fields'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppTextField(
            fieldKey: const Key('auth_full_name_field'),
            controller: _nameController,
            labelText: AppStrings.auth.fullNameLabel,
            hintText: 'Jane Doe',
            prefixIcon: const Icon(Icons.person_outline),
            validator: Validators.validateName,
            enabled: !_isLoading,
          ),
          AppSpacing.gapMd,
          AppTextField(
            fieldKey: const Key('auth_email_field'),
            controller: _emailController,
            labelText: AppStrings.auth.emailLabel,
            hintText: 'email@example.com',
            prefixIcon: const Icon(Icons.mail_outline),
            keyboardType: TextInputType.emailAddress,
            validator: Validators.validateEmail,
            enabled: !_isLoading,
          ),
          AppSpacing.gapMd,
          AppTextField(
            fieldKey: const Key('auth_password_field'),
            controller: _passwordController,
            labelText: AppStrings.auth.passwordLabel,
            hintText: 'At least 8 characters with numbers',
            prefixIcon: const Icon(Icons.lock_outline),
            isPassword: true,
            validator: Validators.validatePassword,
            enabled: !_isLoading,
          ),
          AppSpacing.gapMd,
          AppTextField(
            fieldKey: const Key('auth_confirm_password_field'),
            controller: _confirmPasswordController,
            labelText: AppStrings.auth.confirmPasswordLabel,
            hintText: 'Confirm your password',
            prefixIcon: const Icon(Icons.lock_outline),
            isPassword: true,
            validator: (val) => Validators.validateConfirmPassword(
              val,
              _passwordController.text,
            ),
            enabled: !_isLoading,
          ),
          AppSpacing.gapMd,
          CheckboxListTile(
            key: const Key('auth_terms_checkbox'),
            value: _agreedToTerms,
            onChanged: _isLoading
                ? null
                : (val) => setState(() {
                    _agreedToTerms = val ?? false;
                    if (val == true) _termsCheckboxError = null;
                  }),
            title: Text(
              AppStrings.auth.agreeCheckbox,
              style: theme.textTheme.labelMedium,
            ),
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            activeColor: AppColors.primary,
          ),
          if (_termsCheckboxError != null) ...[
            Padding(
              padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
              child: Text(
                _termsCheckboxError!,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: AppColors.error,
                ),
              ),
            ),
          ],
          AppSpacing.gapMd,
          PrimaryButton(
            buttonKey: const Key('auth_submit_button'),
            label: AppStrings.auth.createAccountButton,
            onPressed: _isLoading ? null : _handleEmailAuth,
            isLoading: _isLoading,
          ),
        ],
      ),
    );
  }
}
