import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../auth/presentation/bloc/auth_provider.dart';
import '../../../emergency/presentation/bloc/emergency_provider.dart';
import '../../../emergency/presentation/widgets/emergency_incident_card.dart';
import '../../../health_monitoring/domain/entities/health_anomaly.dart';
import '../../../health_monitoring/presentation/bloc/health_provider.dart';

class MonitorDashboardPage extends ConsumerWidget {
  const MonitorDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final householdId = user?.householdId ?? '';

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
        child: householdId.isEmpty
            ? _NoHouseholdBody(onJoin: () => context.push('/join'))
            : _HouseholdBody(householdId: householdId),
      ),
    );
  }
}

// ── No household — prompt the monitor to join ──────────────────────────────

class _NoHouseholdBody extends StatelessWidget {
  const _NoHouseholdBody({required this.onJoin});
  final VoidCallback onJoin;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.qr_code_scanner_rounded,
                size: 64,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'Connect to a household',
              style: AppTypography.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Ask the person you\'re monitoring to open the app and share their invite QR code. Then scan it here to start receiving their health alerts.',
              style: AppTypography.body.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            FilledButton.icon(
              onPressed: onJoin,
              icon: const Icon(Icons.qr_code_scanner_rounded),
              label: const Text('Scan invite QR code'),
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, AppSpacing.touchTargetMin),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            OutlinedButton.icon(
              onPressed: onJoin,
              icon: const Icon(Icons.link_rounded),
              label: const Text('Paste invite link'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, AppSpacing.touchTargetMin),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Connected household view ───────────────────────────────────────────────

class _HouseholdBody extends ConsumerWidget {
  const _HouseholdBody({required this.householdId});
  final String householdId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeIncidents =
        ref.watch(activeIncidentsProvider(householdId)).valueOrNull ?? [];
    final anomaliesAsync = ref.watch(anomaliesProvider(householdId));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Active emergency incidents (highest priority)
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
                        acknowledgedBy: ref.read(currentUserProvider)?.uid ?? '',
                      ),
                ),
              ),
            const SizedBox(height: AppSpacing.md),
          ],

          // Status banner
          _StatusBanner(hasActiveIncidents: activeIncidents.isNotEmpty),
          const SizedBox(height: AppSpacing.lg),

          // Recent health anomalies
          Text('Health alerts', style: AppTypography.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          anomaliesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, _) => Text(
              'Unable to load health alerts.',
              style: AppTypography.body.copyWith(color: AppColors.textSecondary),
            ),
            data: (anomalies) => anomalies.isEmpty
                ? _EmptyCard(
                    icon: Icons.health_and_safety_rounded,
                    label: 'No health alerts',
                    subtitle: 'All readings are within normal range',
                  )
                : Column(
                    children: [
                      for (final anomaly in anomalies)
                        Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                          child: _AnomalyCard(anomaly: anomaly),
                        ),
                    ],
                  ),
          ),

          const SizedBox(height: AppSpacing.lg),
          OutlinedButton.icon(
            onPressed: () => context.push('/voice'),
            icon: const Icon(Icons.mic_rounded),
            label: const Text('Ask Hey Guardian'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, AppSpacing.touchTargetMin),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Status banner ──────────────────────────────────────────────────────────

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({required this.hasActiveIncidents});
  final bool hasActiveIncidents;

  @override
  Widget build(BuildContext context) {
    final color = hasActiveIncidents ? AppColors.emergencyRed : AppColors.safeGreen;
    final icon = hasActiveIncidents
        ? Icons.warning_rounded
        : Icons.check_circle_rounded;
    final title = hasActiveIncidents ? 'Emergency active' : 'All clear';
    final subtitle = hasActiveIncidents
        ? 'Respond immediately'
        : 'No active alerts right now';

    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.bodyMedium),
                Text(
                  subtitle,
                  style: AppTypography.label.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Anomaly card ───────────────────────────────────────────────────────────

class _AnomalyCard extends StatelessWidget {
  const _AnomalyCard({required this.anomaly});
  final HealthAnomaly anomaly;

  @override
  Widget build(BuildContext context) {
    final isCritical = anomaly.severity == AnomalySeverity.critical;
    final color = isCritical ? AppColors.emergencyRed : AppColors.warningAmber;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(
            isCritical ? Icons.warning_rounded : Icons.info_outline_rounded,
            color: color,
            size: AppSpacing.iconMd,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(anomaly.message, style: AppTypography.bodyMedium),
                const SizedBox(height: 2),
                Text(
                  _formatTime(anomaly.detectedAt),
                  style: AppTypography.labelSmall
                      .copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _formatTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

// ── Empty state card ───────────────────────────────────────────────────────

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({
    required this.icon,
    required this.label,
    required this.subtitle,
  });

  final IconData icon;
  final String label;
  final String subtitle;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
        child: Column(
          children: [
            Icon(icon, size: 40, color: AppColors.textSecondary),
            const SizedBox(height: AppSpacing.sm),
            Text(
              label,
              style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: AppTypography.label.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
}
