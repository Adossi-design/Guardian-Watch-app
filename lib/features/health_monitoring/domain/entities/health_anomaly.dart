import 'package:equatable/equatable.dart';
import 'health_reading.dart';

enum AnomalySeverity { warning, critical }

enum AnomalyType {
  bradycardia,
  tachycardia,
  hypoxia,
  inactivity;

  String get displayName => switch (this) {
        bradycardia => 'Low Heart Rate',
        tachycardia => 'High Heart Rate',
        hypoxia => 'Low Blood Oxygen',
        inactivity => 'Prolonged Inactivity',
      };
}

class HealthAnomaly extends Equatable {
  const HealthAnomaly({
    required this.id,
    required this.userId,
    required this.householdId,
    required this.type,
    required this.severity,
    required this.reading,
    required this.detectedAt,
    required this.message,
    this.acknowledgedBy,
    this.acknowledgedAt,
  });

  final String id;
  final String userId;
  final String householdId;
  final AnomalyType type;
  final AnomalySeverity severity;
  final HealthReading reading;
  final DateTime detectedAt;
  final String message;
  final String? acknowledgedBy;
  final DateTime? acknowledgedAt;

  bool get isAcknowledged => acknowledgedBy != null;

  @override
  List<Object?> get props => [
        id,
        userId,
        householdId,
        type,
        severity,
        reading,
        detectedAt,
        message,
        acknowledgedBy,
        acknowledgedAt,
      ];
}
