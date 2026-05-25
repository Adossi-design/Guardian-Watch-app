import '../../domain/entities/location_reading.dart';

class LocationReadingModel extends LocationReading {
  const LocationReadingModel({
    required super.userId,
    required super.latitude,
    required super.longitude,
    required super.accuracyMeters,
    required super.timestamp,
  });

  factory LocationReadingModel.fromMap(String userId, Map<dynamic, dynamic> map) =>
      LocationReadingModel(
        userId: userId,
        latitude: (map['lat'] as num).toDouble(),
        longitude: (map['lng'] as num).toDouble(),
        accuracyMeters: (map['accuracy'] as num? ?? 0).toDouble(),
        timestamp: DateTime.fromMillisecondsSinceEpoch(map['ts'] as int),
      );

  factory LocationReadingModel.fromEntity(LocationReading e) =>
      LocationReadingModel(
        userId: e.userId,
        latitude: e.latitude,
        longitude: e.longitude,
        accuracyMeters: e.accuracyMeters,
        timestamp: e.timestamp,
      );

  Map<String, dynamic> toMap() => {
        'lat': latitude,
        'lng': longitude,
        'accuracy': accuracyMeters,
        'ts': timestamp.millisecondsSinceEpoch,
      };
}
