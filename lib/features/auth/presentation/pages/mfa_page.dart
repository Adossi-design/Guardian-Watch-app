import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/validators.dart';
import '../../../../design_system/widgets/guardian_button.dart';

class MfaPage extends StatefulWidget {
  const MfaPage({super.key});

  @override
  State<MfaPage> createState() => _MfaPageState();
}

class _MfaPageState extends State<MfaPage> {
  final _codeCtrl = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _codeCtrl.dispose();
    super.dispose();
  }

  void _verify() {
    final err = Validators.mfaCode(_codeCtrl.text);
    if (err != null) {
      setState(() => _error = err);
      return;
    }
    // MFA verification is handled via Firebase MFA resolver in the auth flow
    // For TOTP: the resolver was passed from the sign-in error handling
    setState(() => _error = null);
  }

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 64,
      textStyle: AppTypography.titleLarge.copyWith(color: AppColors.textPrimary),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.borderLight, width: 1.5),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
    );

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.mfaTitle)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.xl),
              const Icon(Icons.security, color: AppColors.primary, size: 56),
              const SizedBox(height: AppSpacing.lg),
              Text(
                AppStrings.mfaTitle,
                style: AppTypography.headline,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                AppStrings.mfaSubtitle,
                style: AppTypography.body.copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xxl),
              Center(
                child: Pinput(
                  controller: _codeCtrl,
                  length: 6,
                  keyboardType: TextInputType.number,
                  autofocus: true,
                  defaultPinTheme: defaultPinTheme,
                  focusedPinTheme: defaultPinTheme.copyWith(
                    decoration: defaultPinTheme.decoration!.copyWith(
                      border: Border.all(color: AppColors.primary, width: 2),
                    ),
                  ),
                  errorPinTheme: defaultPinTheme.copyWith(
                    decoration: defaultPinTheme.decoration!.copyWith(
                      border: Border.all(color: AppColors.emergencyRed, width: 2),
                    ),
                  ),
                  onCompleted: (_) => _verify(),
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: AppSpacing.md),
                Text(
                  _error!,
                  style: AppTypography.label.copyWith(color: AppColors.emergencyRed),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: AppSpacing.xl),
              GuardianButton(
                label: AppStrings.verifyCode,
                onPressed: _verify,
              ),
              const SizedBox(height: AppSpacing.md),
              Center(
                child: TextButton(
                  onPressed: () => context.pop(),
                  child: const Text('Back to sign in'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
