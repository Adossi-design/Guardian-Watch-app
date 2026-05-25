import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/validators.dart';
import '../../../../design_system/widgets/guardian_button.dart';
import '../bloc/auth_provider.dart';

class SignInPage extends ConsumerStatefulWidget {
  const SignInPage({super.key});

  @override
  ConsumerState<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends ConsumerState<SignInPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    ref.read(authNotifierProvider.notifier).signIn(
          email: _emailCtrl.text,
          password: _passwordCtrl.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState.maybeWhen(
      data: (s) => s is AuthLoading,
      loading: () => true,
      orElse: () => false,
    );
    final error = authState.maybeWhen(
      data: (s) => s is AuthError ? s.message : null,
      orElse: () => null,
    );

    ref.listen(authNotifierProvider, (_, next) {
      next.whenData((state) {
        if (state is AuthAuthenticated) {
          context.go(_roleRoute(state.user.role.name));
        }
      });
    });

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppSpacing.xxl),
                // Logo + title
                Center(
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    ),
                    child: const Icon(Icons.shield_rounded, color: Colors.white, size: 40),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  AppStrings.appName,
                  style: AppTypography.headline,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Sign in to your account',
                  style: AppTypography.body.copyWith(color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xl),
                // Error banner
                if (error != null) ...[
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.emergencyRed.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      border: Border.all(color: AppColors.emergencyRed.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: AppColors.emergencyRed, size: 20),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            error,
                            style: AppTypography.label.copyWith(color: AppColors.emergencyRed),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
                // Email
                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autocorrect: false,
                  decoration: const InputDecoration(
                    labelText: AppStrings.email,
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: Validators.email,
                ),
                const SizedBox(height: AppSpacing.md),
                // Password
                TextFormField(
                  controller: _passwordCtrl,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _submit(),
                  decoration: InputDecoration(
                    labelText: AppStrings.password,
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  validator: (v) => v == null || v.isEmpty ? 'Password is required.' : null,
                ),
                const SizedBox(height: AppSpacing.sm),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => context.push('/forgot-password'),
                    child: const Text(AppStrings.forgotPassword),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                GuardianButton(
                  label: AppStrings.signIn,
                  onPressed: _submit,
                  isLoading: isLoading,
                ),
                const SizedBox(height: AppSpacing.md),
                GuardianButton(
                  label: 'Create account',
                  onPressed: () => context.push('/register'),
                  variant: GuardianButtonVariant.outlined,
                ),
                const SizedBox(height: AppSpacing.lg),
                // Biometric sign-in
                Center(
                  child: TextButton.icon(
                    onPressed: () => ref.read(authNotifierProvider.notifier).authenticateWithBiometrics(),
                    icon: const Icon(Icons.fingerprint),
                    label: const Text('Sign in with biometrics'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _roleRoute(String role) => switch (role) {
        'primary' => '/dashboard/primary',
        'admin' => '/dashboard/admin',
        _ => '/dashboard/monitor',
      };
}
