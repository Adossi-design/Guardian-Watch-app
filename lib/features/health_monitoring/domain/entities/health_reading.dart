import 'package:equatable/equatable.dart';

enum HealthReadingType {
  heartRate,
  bloodOxygen,
  steps,
  activeMinutes;

  String get displayName => switch (this) {
        heartRate => 'Heart Rate',
        bloodOxygen => 'Blood Oxygen',
        steps => 'Steps',
        activeMinutes => 'Active Minutes',
      };

  String get unit => switch (this) {
        heartRate => 'bpm',
        bloodOxygen => '%',
        steps => 'steps',
        activeMinutes => 'min',
      };
}

class HealthReading extends Equatable {
  const HealthReading({
    required this.id,
    required this.userId,
    required this.type,
    required this.value,
    required this.recordedAt,
    this.source,
  });

  final String id;
  final String userId;
  final HealthReadingType type;
  final double value;
  final DateTime recordedAt;
  final String? source;

  @override
  List<Object?> get props => [id, userId, type, value, recordedAt, source];
}
