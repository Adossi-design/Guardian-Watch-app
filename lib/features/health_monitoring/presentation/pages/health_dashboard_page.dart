import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_spacing.dart';
import '../../../../../core/constants/app_typography.dart';
import '../../../auth/presentation/bloc/auth_provider.dart';
import '../bloc/health_provider.dart';
import '../widgets/anomaly_alert_banner.dart';
import '../widgets/health_metric_card.dart';
import '../../domain/entities/health_reading.dart';

class HealthDashboardPage extends ConsumerWidget {
  const HealthDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final healthAsync = ref.watch(healthNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Health'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(healthNotifierProvider.notifier).refresh(),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: healthAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _ErrorView(message: e.toString()),
        data: (state) => switch (state) {
          HealthPermissionRequired() => _PermissionView(
              onRequest: () =>
                  ref.read(healthNotifierProvider.notifier).requestPermissions(),
            ),
          HealthLoading() => const Center(child: CircularProgressIndicator()),
          HealthError(:final message) => _ErrorView(message: message),
          HealthData(:final latestReadings, :final activeAnomaly) =>
            _DataView(readings: latestReadings, activeAnomaly: activeAnomaly),
          _ => const _EmptyView(),
        },
      ),
    );
  }
}

class _DataView extends ConsumerWidget {
  const _DataView({required this.readings, this.activeAnomaly});

  final Map<HealthReadingType, HealthReading?> readings;
  final dynamic activeAnomaly;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    return RefreshIndicator(
      onRefresh: () => ref.read(healthNotifierProvider.notifier).refresh(),
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        children: [
          if (activeAnomaly != null) ...[
            AnomalyAlertBanner(anomaly: activeAnomaly),
            const SizedBox(height: AppSpacing.md),
          ],
          Text('Current readings', style: AppTypography.titleMedium),
          const SizedBox(height: AppSpacing.md),
          for (final type in [
            HealthReadingType.heartRate,
            HealthReadingType.bloodOxygen,
            HealthReadingType.steps,
          ]) ...[
            HealthMetricCard(type: type, reading: readings[type]),
            const SizedBox(height: AppSpacing.sm),
          ],
          const SizedBox(height: AppSpacing.lg),
          if (user != null) ...[
            Text('Recent alerts', style: AppTypography.titleMedium),
            const SizedBox(height: AppSpacing.md),
            _RecentAnomaliesSection(householdId: user.householdId),
          ],
        ],
      ),
    );
  }
}

class _RecentAnomaliesSection extends ConsumerWidget {
  const _RecentAnomaliesSection({required this.householdId});

  final String householdId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final anomaliesAsync = ref.watch(anomaliesProvider(householdId));

    return anomaliesAsync.when(
      loading: () => const SizedBox(
        height: 56,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (_, _) => const SizedBox.shrink(),
      data: (anomalies) {
        if (anomalies.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(AppSpacing.cardPadding),
            decoration: BoxDecoration(
              color: AppColors.activityBg,
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: AppColors.safeGreen),
                const SizedBox(width: AppSpacing.md),
                Text('No recent alerts', style: AppTypography.body),
              ],
            ),
          );
        }
        return Column(
          children: anomalies
              .take(5)
              .map((a) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: AnomalyAlertBanner(anomaly: a),
                  ))
              .toList(),
        );
      },
    );
  }
}

class _PermissionView extends StatelessWidget {
  const _PermissionView({required this.onRequest});

  final VoidCallback onRequest;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.health_and_safety_outlined,
                size: 64, color: AppColors.textSecondary),
            const SizedBox(height: AppSpacing.lg),
            Text('Health access required',
                style: AppTypography.titleLarge, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.md),
            Text(
              'GuardianWatch needs access to your health data to monitor heart rate, blood oxygen, and activity.',
              style: AppTypography.body.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            ElevatedButton(
              onPressed: onRequest,
              child: const Text('Grant access'),
            ),
          ],
        ),
      );
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: Text(message,
              style: AppTypography.body.copyWith(color: AppColors.textSecondary)),
        ),
      );
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) => Center(
        child: Text('No health data',
            style: AppTypography.body.copyWith(color: AppColors.textSecondary)),
      );
}
