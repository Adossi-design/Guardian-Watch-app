import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/health_anomaly.dart';
import 'health_reading_model.dart';

class HealthAnomalyModel extends HealthAnomaly {
  const HealthAnomalyModel({
    required super.id,
    required super.userId,
    required super.householdId,
    required super.type,
    required super.severity,
    required super.reading,
    required super.detectedAt,
    required super.message,
    super.acknowledgedBy,
    super.acknowledgedAt,
  });

  factory HealthAnomalyModel.fromMap(Map<String, dynamic> map) => HealthAnomalyModel(
        id: map['id'] as String,
        userId: map['user_id'] as String,
        householdId: map['household_id'] as String,
        type: AnomalyType.values.byName(map['anomaly_type'] as String),
        severity: AnomalySeverity.values.byName(map['severity'] as String),
        reading: HealthReadingModel.fromMap(
          Map<String, dynamic>.from(map['reading'] as Map),
        ),
        detectedAt: (map['detected_at'] as Timestamp).toDate(),
        message: map['message'] as String,
        acknowledgedBy: map['acknowledged_by'] as String?,
        acknowledgedAt: map['acknowledged_at'] != null
            ? (map['acknowledged_at'] as Timestamp).toDate()
            : null,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'user_id': userId,
        'household_id': householdId,
        'anomaly_type': type.name,
        'severity': severity.name,
        'reading': HealthReadingModel.fromEntity(reading).toMap(),
        'detected_at': Timestamp.fromDate(detectedAt),
        'message': message,
        'acknowledged_by': acknowledgedBy,
        'acknowledged_at':
            acknowledgedAt != null ? Timestamp.fromDate(acknowledgedAt!) : null,
      };

  factory HealthAnomalyModel.fromEntity(HealthAnomaly entity) => HealthAnomalyModel(
        id: entity.id,
        userId: entity.userId,
        householdId: entity.householdId,
        type: entity.type,
        severity: entity.severity,
        reading: entity.reading,
        detectedAt: entity.detectedAt,
        message: entity.message,
        acknowledgedBy: entity.acknowledgedBy,
        acknowledgedAt: entity.acknowledgedAt,
      );
}
