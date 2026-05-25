import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:sensors_plus/sensors_plus.dart';

// 3-phase fall detection per spec:
//   1. Free-fall  — magnitude < 3 m/s² for ≥ 400 ms
//   2. Impact     — magnitude > 25 m/s² immediately after free-fall
//   3. Stillness  — magnitude ≈ 9.81 m/s² (±2) for ≥ 3 s after impact
//
// Thresholds calibrated for wrist-worn devices; tune via remote config in prod.
class FallDetectionService {
  FallDetectionService({required this.onFallDetected});

  final VoidCallback onFallDetected;

  static const double _freeFallThreshold = 3.0;   // m/s²
  static const double _impactThreshold = 25.0;    // m/s²
  static const double _gravity = 9.81;            // m/s²
  static const double _stillnessDeviation = 2.0;  // m/s²

  static const Duration _freeFallMin = Duration(milliseconds: 400);
  static const Duration _freeFallMax = Duration(seconds: 3);
  static const Duration _stillnessRequired = Duration(seconds: 3);
  static const Duration _impactWindow = Duration(seconds: 10);
  static const Duration _cooldown = Duration(seconds: 30);

  StreamSubscription<AccelerometerEvent>? _sub;
  _FallPhase _phase = _FallPhase.idle;
  DateTime? _freeFallStart;
  DateTime? _impactTime;
  DateTime? _stillnessStart;
  DateTime? _lastTrigger;

  void start() {
    _sub = accelerometerEventStream(
      samplingPeriod: const Duration(milliseconds: 50), // 20 Hz
    ).listen(_process, onError: (_) {});
  }

  void stop() {
    _sub?.cancel();
    _sub = null;
    _reset();
  }

  void dispose() => stop();

  void _process(AccelerometerEvent e) {
    final mag = sqrt(e.x * e.x + e.y * e.y + e.z * e.z);
    final now = DateTime.now();

    switch (_phase) {
      case _FallPhase.idle:
        if (mag < _freeFallThreshold) {
          _phase = _FallPhase.freeFall;
          _freeFallStart = now;
        }

      case _FallPhase.freeFall:
        final elapsed = now.difference(_freeFallStart!);
        if (mag > _impactThreshold && elapsed >= _freeFallMin) {
          // Impact detected after valid free-fall window
          _phase = _FallPhase.impacted;
          _impactTime = now;
          _stillnessStart = null;
        } else if (mag >= _freeFallThreshold && elapsed < _freeFallMin) {
          // Jitter — free-fall window too short
          _reset();
        } else if (elapsed > _freeFallMax) {
          // Sustained low-g (e.g. device placed on soft surface) — not a fall
          _reset();
        }

      case _FallPhase.impacted:
        final sinceImpact = now.difference(_impactTime!);
        if (sinceImpact > _impactWindow) {
          _reset();
          return;
        }
        final deviation = (mag - _gravity).abs();
        if (deviation < _stillnessDeviation) {
          _stillnessStart ??= now;
          if (now.difference(_stillnessStart!) >= _stillnessRequired) {
            _trigger();
          }
        } else {
          // Movement after impact — person recovered or device was kicked
          _stillnessStart = null;
        }
    }
  }

  void _trigger() {
    final now = DateTime.now();
    if (_lastTrigger != null && now.difference(_lastTrigger!) < _cooldown) {
      _reset();
      return;
    }
    _lastTrigger = now;
    _reset();
    onFallDetected();
  }

  void _reset() {
    _phase = _FallPhase.idle;
    _freeFallStart = null;
    _impactTime = null;
    _stillnessStart = null;
  }
}

enum _FallPhase { idle, freeFall, impacted }
