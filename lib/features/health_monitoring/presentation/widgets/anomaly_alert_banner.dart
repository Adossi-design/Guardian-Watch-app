import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_spacing.dart';
import '../../../../../core/constants/app_typography.dart';
import '../../domain/entities/health_anomaly.dart';

class AnomalyAlertBanner extends StatelessWidget {
  const AnomalyAlertBanner({
    super.key,
    required this.anomaly,
    this.onAcknowledge,
    this.showAcknowledgeButton = false,
  });

  final HealthAnomaly anomaly;
  final VoidCallback? onAcknowledge;
  final bool showAcknowledgeButton;

  @override
  Widget build(BuildContext context) {
    final isCritical = anomaly.severity == AnomalySeverity.critical;
    final color = isCritical ? AppColors.emergencyRed : AppColors.warningAmber;
    final bgColor = color.withValues(alpha: 0.08);
    final borderColor = color.withValues(alpha: 0.35);

    return Semantics(
      label: 'Health alert: ${anomaly.message}',
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              isCritical ? Icons.emergency_rounded : Icons.warning_amber_rounded,
              color: color,
              size: AppSpacing.iconMd,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    anomaly.type.displayName,
                    style: AppTypography.bodyMedium.copyWith(color: color),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    anomaly.message,
                    style: AppTypography.label.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(anomaly.detectedAt),
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (showAcknowledgeButton && !anomaly.isAcknowledged)
              TextButton(
                onPressed: onAcknowledge,
                style: TextButton.styleFrom(
                  foregroundColor: color,
                  minimumSize: const Size(56, AppSpacing.touchTargetMin),
                  padding: EdgeInsets.zero,
                ),
                child: const Text('OK'),
              ),
            if (anomaly.isAcknowledged)
              Icon(
                Icons.check_circle_rounded,
                color: AppColors.safeGreen,
                size: AppSpacing.iconMd,
              ),
          ],
        ),
      ),
    );
  }

  static String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
