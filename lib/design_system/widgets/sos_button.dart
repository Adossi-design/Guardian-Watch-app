import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';

class SosButton extends StatefulWidget {
  const SosButton({super.key, required this.onActivated});

  final VoidCallback onActivated;

  @override
  State<SosButton> createState() => _SosButtonState();
}

class _SosButtonState extends State<SosButton> with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _onPressed() {
    HapticFeedback.heavyImpact();
    widget.onActivated();
  }

  @override
  Widget build(BuildContext context) {
    // SOS button: 120×120dp — always visible, never hidden behind UI
    return Semantics(
      label: 'SOS emergency button',
      button: true,
      child: ScaleTransition(
        scale: _pulseAnimation,
        child: GestureDetector(
          onTap: _onPressed,
          child: Container(
            width: AppSpacing.sosButtonSize,
            height: AppSpacing.sosButtonSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.emergencyRed,
              boxShadow: [
                BoxShadow(
                  color: AppColors.emergencyRed.withValues(alpha: 0.4),
                  blurRadius: 20,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: Center(
              child: Text(
                'SOS',
                style: AppTypography.inter(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
