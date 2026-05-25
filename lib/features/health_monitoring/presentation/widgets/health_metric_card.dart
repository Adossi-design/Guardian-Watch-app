import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_spacing.dart';
import '../../../../../core/constants/app_typography.dart';
import '../../domain/entities/health_reading.dart';

class HealthMetricCard extends StatelessWidget {
  const HealthMetricCard({
    super.key,
    required this.type,
    required this.reading,
    this.onTap,
  });

  final HealthReadingType type;
  final HealthReading? reading;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final config = _config(type);
    final value = reading?.value;
    final isAbnormal = value != null && _isAbnormal(type, value);

    return Semantics(
      label: '${type.displayName}: ${value != null ? '${value.toStringAsFixed(0)} ${type.unit}' : 'No data'}',
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.cardPadding),
          decoration: BoxDecoration(
            color: isAbnormal
                ? AppColors.emergencyRed.withValues(alpha: 0.08)
                : config.bgColor,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            border: isAbnormal
                ? Border.all(color: AppColors.emergencyRed.withValues(alpha: 0.4))
                : null,
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: (isAbnormal ? AppColors.emergencyRed : config.iconColor)
                      .withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: Icon(
                  config.icon,
                  color: isAbnormal ? AppColors.emergencyRed : config.iconColor,
                  size: AppSpacing.iconMd,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      type.displayName,
                      style: AppTypography.label.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    value != null
                        ? RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: value.toStringAsFixed(0),
                                  style: AppTypography.titleLarge.copyWith(
                                    color: isAbnormal
                                        ? AppColors.emergencyRed
                                        : AppColors.textPrimary,
                                  ),
                                ),
                                TextSpan(
                                  text: ' ${type.unit}',
                                  style: AppTypography.label.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Text(
                            'No data',
                            style: AppTypography.body.copyWith(
                              color: AppColors.textDisabled,
                            ),
                          ),
                  ],
                ),
              ),
              if (isAbnormal)
                const Icon(
                  Icons.warning_rounded,
                  color: AppColors.emergencyRed,
                  size: AppSpacing.iconMd,
                ),
            ],
          ),
        ),
      ),
    );
  }

  static bool _isAbnormal(HealthReadingType type, double value) =>
      switch (type) {
        HealthReadingType.heartRate => value < 45 || value > 130,
        HealthReadingType.bloodOxygen => value < 90,
        _ => false,
      };

  static _MetricConfig _config(HealthReadingType type) => switch (type) {
        HealthReadingType.heartRate => const _MetricConfig(
            icon: Icons.favorite_rounded,
            iconColor: AppColors.emergencyRed,
            bgColor: AppColors.heartRateBg,
          ),
        HealthReadingType.bloodOxygen => const _MetricConfig(
            icon: Icons.water_drop_rounded,
            iconColor: AppColors.primary,
            bgColor: AppColors.spo2Bg,
          ),
        HealthReadingType.steps => const _MetricConfig(
            icon: Icons.directions_walk_rounded,
            iconColor: AppColors.safeGreen,
            bgColor: AppColors.activityBg,
          ),
        HealthReadingType.activeMinutes => const _MetricConfig(
            icon: Icons.timer_rounded,
            iconColor: AppColors.safeGreen,
            bgColor: AppColors.activityBg,
          ),
      };
}

class _MetricConfig {
  const _MetricConfig({
    required this.icon,
    required this.iconColor,
    required this.bgColor,
  });

  final IconData icon;
  final Color iconColor;
  final Color bgColor;
}
