import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';

enum GuardianButtonVariant { primary, outlined, text, danger }

class GuardianButton extends StatelessWidget {
  const GuardianButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = GuardianButtonVariant.primary,
    this.isLoading = false,
    this.icon,
    this.width,
    this.height = AppSpacing.touchTargetMin,
  });

  final String label;
  final VoidCallback? onPressed;
  final GuardianButtonVariant variant;
  final bool isLoading;
  final IconData? icon;
  final double? width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: _buildButton(context),
    );
  }

  Widget _buildButton(BuildContext context) {
    final child = isLoading
        ? const SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: Colors.white,
            ),
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: AppSpacing.iconMd),
                const SizedBox(width: AppSpacing.sm),
              ],
              Text(label, style: AppTypography.button),
            ],
          );

    switch (variant) {
      case GuardianButtonVariant.primary:
        return ElevatedButton(
          onPressed: isLoading ? null : _withHaptic(onPressed),
          child: child,
        );
      case GuardianButtonVariant.outlined:
        return OutlinedButton(
          onPressed: isLoading ? null : _withHaptic(onPressed),
          child: child,
        );
      case GuardianButtonVariant.text:
        return TextButton(
          onPressed: isLoading ? null : _withHaptic(onPressed),
          child: child,
        );
      case GuardianButtonVariant.danger:
        return ElevatedButton(
          onPressed: isLoading ? null : _withHaptic(onPressed),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.emergencyRed,
            foregroundColor: Colors.white,
          ),
          child: child,
        );
    }
  }

  VoidCallback? _withHaptic(VoidCallback? callback) {
    if (callback == null) return null;
    return () {
      HapticFeedback.lightImpact();
      callback();
    };
  }
}
