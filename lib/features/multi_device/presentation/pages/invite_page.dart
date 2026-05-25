import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../design_system/widgets/guardian_button.dart';
import '../../../auth/presentation/bloc/auth_provider.dart';
import '../bloc/invite_provider.dart';

class InvitePage extends ConsumerWidget {
  const InvitePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inviteState = ref.watch(inviteNotifierProvider);
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Invite monitors')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: inviteState.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
            data: (state) => _buildBody(context, ref, state, user?.householdId ?? ''),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    InviteState state,
    String householdId,
  ) {
    if (state is InviteCreated) {
      final inviteLink = 'guardianwatch://invite/${state.invite.inviteId}';
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.cardPadding),
            decoration: BoxDecoration(
              color: AppColors.safeGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              border: Border.all(color: AppColors.safeGreen.withValues(alpha: 0.3)),
            ),
            child: Column(
              children: [
                const Icon(Icons.check_circle_rounded, color: AppColors.safeGreen, size: 48),
                const SizedBox(height: AppSpacing.md),
                Text(AppStrings.inviteSent, style: AppTypography.titleMedium),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  AppStrings.inviteExpiry,
                  style: AppTypography.body.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('Share this link:', style: AppTypography.bodyMedium),
          const SizedBox(height: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    inviteLink,
                    style: AppTypography.label,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: inviteLink));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Link copied to clipboard')),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          GuardianButton(
            label: 'Generate new link',
            onPressed: () {
              ref.read(inviteNotifierProvider.notifier).reset();
              ref.read(inviteNotifierProvider.notifier).createInvite(householdId);
            },
            variant: GuardianButtonVariant.outlined,
          ),
        ],
      );
    }

    if (state is InviteError) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.emergencyRed.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: Text(
              state.message,
              style: AppTypography.body.copyWith(color: AppColors.emergencyRed),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          GuardianButton(
            label: AppStrings.retry,
            onPressed: () => ref.read(inviteNotifierProvider.notifier).createInvite(householdId),
          ),
        ],
      );
    }

    // Idle state
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: AppSpacing.lg),
        const Icon(Icons.people_rounded, size: 64, color: AppColors.primary),
        const SizedBox(height: AppSpacing.lg),
        Text(
          'Invite caregivers & family',
          style: AppTypography.headline,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Generate a secure invite link. Anyone with this link can connect to your account and receive all health alerts in real time.\n\nYou can invite unlimited people.',
          style: AppTypography.body.copyWith(color: AppColors.textSecondary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xl),
        GuardianButton(
          label: AppStrings.generateInvite,
          onPressed: householdId.isEmpty
              ? null
              : () => ref.read(inviteNotifierProvider.notifier).createInvite(householdId),
          icon: Icons.link,
        ),
        if (householdId.isEmpty) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Complete your profile setup first.',
            style: AppTypography.label.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}
