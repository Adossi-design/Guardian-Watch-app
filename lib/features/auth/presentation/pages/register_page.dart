import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/validators.dart';
import '../../../../design_system/widgets/guardian_button.dart';
import '../../domain/entities/user_entity.dart';
import '../bloc/auth_provider.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  UserRole _selectedRole = UserRole.primary;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    ref.read(authNotifierProvider.notifier).register(
          email: _emailCtrl.text,
          password: _passwordCtrl.text,
          name: _nameCtrl.text,
          phone: _phoneCtrl.text,
          role: _selectedRole,
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
      appBar: AppBar(title: const Text(AppStrings.signUp)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (error != null) ...[
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.emergencyRed.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      border: Border.all(color: AppColors.emergencyRed.withValues(alpha: 0.3)),
                    ),
                    child: Text(error, style: AppTypography.label.copyWith(color: AppColors.emergencyRed)),
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
                // Role selector
                Text('I am a…', style: AppTypography.titleMedium),
                const SizedBox(height: AppSpacing.sm),
                _RoleSelector(
                  selected: _selectedRole,
                  onChanged: (r) => setState(() => _selectedRole = r),
                ),
                const SizedBox(height: AppSpacing.lg),
                // Full name
                TextFormField(
                  controller: _nameCtrl,
                  keyboardType: TextInputType.name,
                  textInputAction: TextInputAction.next,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: AppStrings.fullName,
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: Validators.fullName,
                ),
                const SizedBox(height: AppSpacing.md),
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
                TextFormField(
                  controller: _phoneCtrl,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: AppStrings.phoneNumber,
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
                  validator: Validators.phoneNumber,
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _passwordCtrl,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: AppStrings.password,
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  validator: Validators.password,
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _confirmCtrl,
                  obscureText: _obscureConfirm,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _submit(),
                  decoration: InputDecoration(
                    labelText: AppStrings.confirmPassword,
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(_obscureConfirm ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                      onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                    ),
                  ),
                  validator: (v) => Validators.confirmPassword(v, _passwordCtrl.text),
                ),
                const SizedBox(height: AppSpacing.xl),
                GuardianButton(
                  label: AppStrings.signUp,
                  onPressed: _submit,
                  isLoading: isLoading,
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Already have an account?', style: AppTypography.body),
                    TextButton(
                      onPressed: () => context.pop(),
                      child: const Text(AppStrings.signIn),
                    ),
                  ],
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

class _RoleSelector extends StatelessWidget {
  const _RoleSelector({required this.selected, required this.onChanged});
  final UserRole selected;
  final ValueChanged<UserRole> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _RoleChip(
          label: 'Primary User',
          subtitle: 'I wear the watch',
          icon: Icons.watch_rounded,
          isSelected: selected == UserRole.primary,
          onTap: () => onChanged(UserRole.primary),
        ),
        const SizedBox(width: AppSpacing.sm),
        _RoleChip(
          label: 'Caregiver',
          subtitle: 'I monitor someone',
          icon: Icons.favorite_rounded,
          isSelected: selected == UserRole.monitor,
          onTap: () => onChanged(UserRole.monitor),
        ),
      ],
    );
  }
}

class _RoleChip extends StatelessWidget {
  const _RoleChip({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.1)
                : Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.borderLight,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? AppColors.primary : AppColors.textSecondary, size: 28),
              const SizedBox(height: AppSpacing.sm),
              Text(
                label,
                style: AppTypography.bodyMedium.copyWith(
                  color: isSelected ? AppColors.primary : AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                subtitle,
                style: AppTypography.labelSmall.copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
