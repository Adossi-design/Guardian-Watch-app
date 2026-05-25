import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';

class HealthMetricTile extends StatelessWidget {
  const HealthMetricTile({
    super.key,
    required this.label,
    required this.value,
    required this.unit,
    required this.icon,
    required this.backgroundColor,
    required this.iconColor,
    this.isNormal = true,
    this.trend,
    this.onTap,
  });

  final String label;
  final String value;
  final String unit;
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;
  final bool isNormal;
  final String? trend;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$label: $value $unit',
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.cardPadding),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            border: Border.all(
              color: isNormal
                  ? backgroundColor.withValues(alpha: 0.0)
                  : AppColors.emergencyRed.withValues(alpha: 0.4),
              width: isNormal ? 0 : 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: iconColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    ),
                    child: Icon(icon, color: iconColor, size: AppSpacing.iconMd),
                  ),
                  if (!isNormal)
                    Icon(
                      Icons.warning_rounded,
                      color: AppColors.emergencyRed,
                      size: AppSpacing.iconMd,
                      semanticLabel: 'Abnormal reading',
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(value, style: AppTypography.headline.copyWith(color: AppColors.textPrimary)),
                  const SizedBox(width: 4),
                  Text(unit, style: AppTypography.label.copyWith(color: AppColors.textSecondary)),
                ],
              ),
              const SizedBox(height: 4),
              Text(label, style: AppTypography.label.copyWith(color: AppColors.textSecondary)),
              if (trend != null) ...[
                const SizedBox(height: 4),
                Text(trend!, style: AppTypography.labelSmall.copyWith(color: AppColors.textSecondary)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
