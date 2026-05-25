import 'package:health/health.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/health_reading.dart';

@lazySingleton
class HealthLocalDataSource {
  final Health _health = Health();
  bool _configured = false;
  static const _uuid = Uuid();

  static const Map<HealthReadingType, HealthDataType> _typeMap = {
    HealthReadingType.heartRate: HealthDataType.HEART_RATE,
    HealthReadingType.bloodOxygen: HealthDataType.BLOOD_OXYGEN,
    HealthReadingType.steps: HealthDataType.STEPS,
    HealthReadingType.activeMinutes: HealthDataType.ACTIVE_ENERGY_BURNED,
  };

  Future<void> _ensureConfigured() async {
    if (_configured) return;
    await _health.configure();
    _configured = true;
  }

  Future<bool> hasPermissions(List<HealthReadingType> types) async {
    await _ensureConfigured();
    return await _health.hasPermissions(_toDataTypes(types)) ?? false;
  }

  Future<bool> requestPermissions(List<HealthReadingType> types) async {
    await _ensureConfigured();
    return _health.requestAuthorization(_toDataTypes(types));
  }

  Future<List<HealthReading>> fetchReadings({
    required String userId,
    required List<HealthReadingType> types,
    required Duration window,
  }) async {
    await _ensureConfigured();

    final hasPerms = await _health.hasPermissions(_toDataTypes(types)) ?? false;
    if (!hasPerms) return [];

    final now = DateTime.now();
    final points = await _health.getHealthDataFromTypes(
      types: _toDataTypes(types),
      startTime: now.subtract(window),
      endTime: now,
    );

    return points
        .where((p) => p.value is NumericHealthValue)
        .map(
          (p) => HealthReading(
            id: _uuid.v4(),
            userId: userId,
            type: _fromDataType(p.type),
            value: (p.value as NumericHealthValue).numericValue.toDouble(),
            recordedAt: p.dateFrom,
            source: p.sourceName,
          ),
        )
        .toList();
  }

  List<HealthDataType> _toDataTypes(List<HealthReadingType> types) =>
      types.map((t) => _typeMap[t]!).toList();

  HealthReadingType _fromDataType(HealthDataType dataType) {
    for (final entry in _typeMap.entries) {
      if (entry.value == dataType) return entry.key;
    }
    return HealthReadingType.heartRate;
  }
}
