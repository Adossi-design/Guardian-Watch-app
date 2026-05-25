import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';

class EmergencyCountdown extends StatefulWidget {
  const EmergencyCountdown({
    super.key,
    required this.seconds,
    required this.onCountdownComplete,
    required this.onCancelled,
    required this.message,
  });

  final int seconds;
  final VoidCallback onCountdownComplete;
  final VoidCallback onCancelled;
  final String message;

  @override
  State<EmergencyCountdown> createState() => _EmergencyCountdownState();
}

class _EmergencyCountdownState extends State<EmergencyCountdown> {
  late int _remaining;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _remaining = widget.seconds;
    _startTimer();
    // Haptic pulse every second during countdown
    HapticFeedback.heavyImpact();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_remaining <= 1) {
        t.cancel();
        widget.onCountdownComplete();
      } else {
        setState(() => _remaining--);
        HapticFeedback.mediumImpact();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Full-screen takeover — per spec
    return Scaffold(
      backgroundColor: AppColors.emergencyRed,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.message,
                style: AppTypography.emergencyTitle.copyWith(color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xxl),
              // Countdown circle
              Center(
                child: SizedBox(
                  width: 160,
                  height: 160,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: _remaining / widget.seconds,
                        strokeWidth: 8,
                        backgroundColor: Colors.white.withValues(alpha: 0.3),
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                      Text(
                        '$_remaining',
                        style: AppTypography.display.copyWith(
                          color: Colors.white,
                          fontSize: 64,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              // "I AM OK" — entire-screen-width button per spec
              SizedBox(
                height: 80,
                child: ElevatedButton(
                  onPressed: () {
                    HapticFeedback.heavyImpact();
                    _timer?.cancel();
                    widget.onCancelled();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.emergencyRed,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                    ),
                  ),
                  child: Text(
                    'I AM OK',
                    style: AppTypography.emergencyTitle.copyWith(
                      color: AppColors.emergencyRed,
                      fontSize: 28,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
