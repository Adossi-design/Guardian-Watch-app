import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/health_reading.dart';

class HealthReadingModel extends HealthReading {
  const HealthReadingModel({
    required super.id,
    required super.userId,
    required super.type,
    required super.value,
    required super.recordedAt,
    super.source,
  });

  factory HealthReadingModel.fromMap(Map<String, dynamic> map) => HealthReadingModel(
        id: map['id'] as String,
        userId: map['user_id'] as String,
        type: HealthReadingType.values.byName(map['type'] as String),
        value: (map['value'] as num).toDouble(),
        recordedAt: (map['recorded_at'] as Timestamp).toDate(),
        source: map['source'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'user_id': userId,
        'type': type.name,
        'value': value,
        'recorded_at': Timestamp.fromDate(recordedAt),
        'source': source,
      };

  factory HealthReadingModel.fromEntity(HealthReading entity) => HealthReadingModel(
        id: entity.id,
        userId: entity.userId,
        type: entity.type,
        value: entity.value,
        recordedAt: entity.recordedAt,
        source: entity.source,
      );
}
