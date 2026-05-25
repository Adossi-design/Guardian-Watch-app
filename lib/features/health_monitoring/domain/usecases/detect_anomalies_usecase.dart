import 'package:uuid/uuid.dart';
import '../entities/health_anomaly.dart';
import '../entities/health_reading.dart';

// Pure domain logic — no I/O, synchronous, fully testable.
// Rules per spec: HR < 45 = bradycardia, HR > 130 = tachycardia,
// SpO2 < 90 = hypoxia, no steps for 4 h = inactivity.
class DetectAnomaliesUseCase {
  const DetectAnomaliesUseCase();

  static const _uuid = Uuid();
  static const double _hrLow = 45.0;
  static const double _hrHigh = 130.0;
  static const double _spO2Low = 90.0;
  static const int _inactivityMinutes = 240;

  List<HealthAnomaly> call({
    required List<HealthReading> readings,
    required String userId,
    required String householdId,
  }) {
    final anomalies = <HealthAnomaly>[];

    for (final reading in readings) {
      final anomaly = _evaluateReading(reading, userId, householdId);
      if (anomaly != null) anomalies.add(anomaly);
    }

    final inactivity = _checkInactivity(readings, userId, householdId);
    if (inactivity != null) anomalies.add(inactivity);

    return anomalies;
  }

  HealthAnomaly? _evaluateReading(
    HealthReading r,
    String userId,
    String householdId,
  ) =>
      switch (r.type) {
        HealthReadingType.heartRate => _evaluateHeartRate(r, userId, householdId),
        HealthReadingType.bloodOxygen => _evaluateSpO2(r, userId, householdId),
        _ => null,
      };

  HealthAnomaly? _evaluateHeartRate(HealthReading r, String userId, String householdId) {
    if (r.value < _hrLow) {
      return _build(
        userId: userId,
        householdId: householdId,
        reading: r,
        type: AnomalyType.bradycardia,
        severity: AnomalySeverity.critical,
        message: 'Heart rate critically low: ${r.value.toInt()} bpm',
      );
    }
    if (r.value > _hrHigh) {
      return _build(
        userId: userId,
        householdId: householdId,
        reading: r,
        type: AnomalyType.tachycardia,
        severity: AnomalySeverity.critical,
        message: 'Heart rate critically high: ${r.value.toInt()} bpm',
      );
    }
    return null;
  }

  HealthAnomaly? _evaluateSpO2(HealthReading r, String userId, String householdId) {
    if (r.value < _spO2Low) {
      return _build(
        userId: userId,
        householdId: householdId,
        reading: r,
        type: AnomalyType.hypoxia,
        severity: AnomalySeverity.critical,
        message: 'Blood oxygen critically low: ${r.value.toInt()}%',
      );
    }
    return null;
  }

  HealthAnomaly? _checkInactivity(
    List<HealthReading> readings,
    String userId,
    String householdId,
  ) {
    final steps = readings
        .where((r) => r.type == HealthReadingType.steps)
        .toList()
      ..sort((a, b) => a.recordedAt.compareTo(b.recordedAt));

    if (steps.length < 2) return null;

    final span = steps.last.recordedAt.difference(steps.first.recordedAt);
    if (span.inMinutes < _inactivityMinutes) return null;

    final total = steps.fold(0.0, (s, r) => s + r.value);
    if (total >= 10) return null;

    return _build(
      userId: userId,
      householdId: householdId,
      reading: steps.last,
      type: AnomalyType.inactivity,
      severity: AnomalySeverity.warning,
      message: 'No activity detected for ${span.inHours}h',
    );
  }

  HealthAnomaly _build({
    required String userId,
    required String householdId,
    required HealthReading reading,
    required AnomalyType type,
    required AnomalySeverity severity,
    required String message,
  }) =>
      HealthAnomaly(
        id: _uuid.v4(),
        userId: userId,
        householdId: householdId,
        type: type,
        severity: severity,
        reading: reading,
        detectedAt: DateTime.now(),
        message: message,
      );
}
