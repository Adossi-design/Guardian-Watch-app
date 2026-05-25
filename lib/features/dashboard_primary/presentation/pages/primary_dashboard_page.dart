import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../design_system/widgets/sos_button.dart';
import '../../../auth/presentation/bloc/auth_provider.dart';
import '../../../emergency/domain/entities/emergency_incident.dart';
import '../../../emergency/presentation/bloc/emergency_provider.dart';
import '../../../health_monitoring/domain/entities/health_reading.dart';
import '../../../health_monitoring/presentation/bloc/health_provider.dart';
import '../../../health_monitoring/presentation/widgets/anomaly_alert_banner.dart';
import '../../../health_monitoring/presentation/widgets/health_metric_card.dart';

class PrimaryDashboardPage extends ConsumerStatefulWidget {
  const PrimaryDashboardPage({super.key});

  @override
  ConsumerState<PrimaryDashboardPage> createState() =>
      _PrimaryDashboardPageState();
}

class _PrimaryDashboardPageState extends ConsumerState<PrimaryDashboardPage> {
  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<EmergencyState>>(emergencyNotifierProvider,
        (_, next) {
      final state = next.valueOrNull;
      if (state is EmergencyCountdownState) {
        context.go('/emergency/countdown');
      } else if (state is EmergencyActiveState) {
        context.go('/emergency/active');
      }
    });

    final user = ref.watch(currentUserProvider);
    final healthAsync = ref.watch(healthNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Hi, ${user?.name.split(' ').first ?? 'Guardian'}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.screenPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Active anomaly banner
                  healthAsync.whenData((s) => s).valueOrNull.let((s) {
                    if (s is HealthData && s.activeAnomaly != null) {
                      return Column(children: [
                        AnomalyAlertBanner(anomaly: s.activeAnomaly!),
                        const SizedBox(height: AppSpacing.md),
                      ]);
                    }
                    return const SizedBox.shrink();
                  }),

                  // Health metrics
                  Text('Your health', style: AppTypography.titleMedium),
                  const SizedBox(height: AppSpacing.md),
                  healthAsync.when(
                    loading: () => const _HealthLoadingCard(),
                    error: (_, _) => const _HealthErrorCard(),
                    data: (state) => switch (state) {
                      HealthPermissionRequired() => _HealthPermissionCard(
                          onRequest: () => ref
                              .read(healthNotifierProvider.notifier)
                              .requestPermissions(),
                        ),
                      HealthData(:final latestReadings) => Column(
                          children: [
                            for (final type in [
                              HealthReadingType.heartRate,
                              HealthReadingType.bloodOxygen,
                              HealthReadingType.steps,
                            ]) ...[
                              HealthMetricCard(
                                type: type,
                                reading: latestReadings[type],
                                onTap: () => context.push('/health'),
                              ),
                              const SizedBox(height: AppSpacing.sm),
                            ],
                          ],
                        ),
                      _ => const _HealthLoadingCard(),
                    },
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // Safe zone card
                  _StatusCard(
                    title: 'Safe zone',
                    subtitle: 'Tap to manage zones',
                    icon: Icons.location_on_rounded,
                    color: AppColors.activityBg,
                    iconColor: AppColors.safeGreen,
                    onTap: () => context.push('/geofence'),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Monitors card
                  _StatusCard(
                    title: 'Connected monitors',
                    subtitle: 'Invite family or caregivers',
                    icon: Icons.people_rounded,
                    color: AppColors.spo2Bg,
                    iconColor: AppColors.primary,
                    onTap: () => context.push('/invite'),
                  ),

                  const SizedBox(height: 140),
                ],
              ),
            ),

            // SOS — always visible, per spec
            Positioned(
              bottom: AppSpacing.xl,
              left: 0,
              right: 0,
              child: Center(
                child: SosButton(
                  onActivated: () => ref
                      .read(emergencyNotifierProvider.notifier)
                      .triggerEmergency(EmergencyTriggerType.sosManual),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Local helpers ─────────────────────────────────────────────────────────────

class _HealthLoadingCard extends StatelessWidget {
  const _HealthLoadingCard();

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        decoration: BoxDecoration(
          color: AppColors.heartRateBg,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
}

class _HealthErrorCard extends StatelessWidget {
  const _HealthErrorCard();

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        decoration: BoxDecoration(
          color: AppColors.heartRateBg,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
        child: Text(
          'Unable to load health data',
          style: AppTypography.body.copyWith(color: AppColors.textSecondary),
        ),
      );
}

class _HealthPermissionCard extends StatelessWidget {
  const _HealthPermissionCard({required this.onRequest});

  final VoidCallback onRequest;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        decoration: BoxDecoration(
          color: AppColors.heartRateBg,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Health access needed', style: AppTypography.bodyMedium),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Tap to grant access and start monitoring.',
              style: AppTypography.label.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.md),
            OutlinedButton(
              onPressed: onRequest,
              child: const Text('Grant access'),
            ),
          ],
        ),
      );
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.iconColor,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Color iconColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.cardPadding),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: Icon(icon, color: iconColor, size: AppSpacing.iconLg),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTypography.bodyMedium),
                    Text(
                      subtitle,
                      style: AppTypography.label
                          .copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              if (onTap != null)
                const Icon(Icons.chevron_right, color: AppColors.textSecondary),
            ],
          ),
        ),
      );
}

// Small helper to allow null-safe chaining on nullable values
extension _LetX<T> on T? {
  R let<R>(R Function(T?) f) => f(this);
}
