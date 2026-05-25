import 'package:flutter/material.dart';
import '../../core/constants/app_spacing.dart';

class GuardianCard extends StatelessWidget {
  const GuardianCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.color,
    this.borderColor,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final Color? color;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: color ?? theme.cardTheme.color,
      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        child: Container(
          padding: padding ?? const EdgeInsets.all(AppSpacing.cardPadding),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            border: Border.all(
              color: borderColor ?? theme.colorScheme.outline,
              width: 1,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
