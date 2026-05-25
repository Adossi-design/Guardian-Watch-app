import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';

class VoiceListeningIndicator extends StatefulWidget {
  const VoiceListeningIndicator({
    super.key,
    required this.isListening,
    required this.transcript,
    required this.onStop,
  });

  final bool isListening;
  final String transcript;
  final VoidCallback onStop;

  @override
  State<VoiceListeningIndicator> createState() => _VoiceListeningIndicatorState();
}

class _VoiceListeningIndicatorState extends State<VoiceListeningIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _rippleController;
  late final Animation<double> _rippleAnimation;

  @override
  void initState() {
    super.initState();
    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    _rippleAnimation = Tween<double>(begin: 0.8, end: 1.4).animate(
      CurvedAnimation(parent: _rippleController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _rippleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              if (widget.isListening)
                ScaleTransition(
                  scale: _rippleAnimation,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary.withValues(alpha: 0.15),
                    ),
                  ),
                ),
              GestureDetector(
                onTap: widget.onStop,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.isListening ? AppColors.primary : AppColors.textSecondary,
                  ),
                  child: Icon(
                    widget.isListening ? Icons.mic : Icons.mic_off,
                    color: Colors.white,
                    size: AppSpacing.iconLg,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            widget.isListening ? 'Listening…' : 'Tap to speak',
            style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
          ),
          if (widget.transcript.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              widget.transcript,
              style: AppTypography.body,
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}
