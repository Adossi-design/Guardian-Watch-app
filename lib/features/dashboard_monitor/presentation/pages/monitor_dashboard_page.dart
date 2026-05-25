import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../auth/presentation/bloc/auth_provider.dart';
import '../../../emergency/presentation/bloc/emergency_provider.dart';
import '../../../emergency/presentation/widgets/emergency_incident_card.dart';

class MonitorDashboardPage extends ConsumerWidget {
  const MonitorDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final householdId = user?.householdId ?? '';
    final activeIncidents =
        ref.watch(activeIncidentsProvider(householdId)).valueOrNull ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text('Hi, ${user?.name.split(' ').first ?? 'Monitor'}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Active emergency incidents
              if (activeIncidents.isNotEmpty) ...[
                Text('Active emergencies', style: AppTypography.titleMedium),
                const SizedBox(height: AppSpacing.sm),
                for (final incident in activeIncidents)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: EmergencyIncidentCard(
                      incident: incident,
                      onAcknowledge: () => ref
                          .read(emergencyNotifierProvider.notifier)
                          .acknowledgeEmergency(
                            incidentId: incident.id,
                            acknowledgedBy: user?.uid ?? '',
                          ),
                    ),
                  ),
                const SizedBox(height: AppSpacing.md),
              ],

              // Status banner
              Container(
                padding: const EdgeInsets.all(AppSpacing.cardPadding),
                decoration: BoxDecoration(
                  color: AppColors.safeGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                  border: Border.all(color: AppColors.safeGreen.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_rounded, color: AppColors.safeGreen, size: 28),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('All clear', style: AppTypography.bodyMedium),
                          Text(
                            'No active alerts',
                            style: AppTypography.label.copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text('Primary users', style: AppTypography.titleMedium),
              const SizedBox(height: AppSpacing.md),
              Container(
                padding: const EdgeInsets.all(AppSpacing.cardPadding),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.people_outlined, size: 48, color: AppColors.textSecondary),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'No primary users yet',
                      style: AppTypography.body.copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Ask the primary user to send you an invite link',
                      style: AppTypography.label.copyWith(color: AppColors.textSecondary),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              // Voice AI assistant button — Phase 5 feature
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.mic),
                label: const Text('Ask Hey Guardian'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, AppSpacing.touchTargetMin),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
