import '../../domain/entities/geofence_breach.dart';

class GeofenceBreachModel extends GeofenceBreach {
  const GeofenceBreachModel({
    required super.id,
    required super.userId,
    required super.householdId,
    required super.zoneId,
    required super.zoneName,
    required super.type,
    required super.latitude,
    required super.longitude,
    required super.timestamp,
    super.isWandering,
  });

  factory GeofenceBreachModel.fromMap(String id, Map<String, dynamic> map) =>
      GeofenceBreachModel(
        id: id,
        userId: map['userId'] as String,
        householdId: map['householdId'] as String,
        zoneId: map['zoneId'] as String,
        zoneName: map['zoneName'] as String,
        type: map['type'] == 'enter' ? BreachType.enter : BreachType.exit,
        latitude: (map['latitude'] as num).toDouble(),
        longitude: (map['longitude'] as num).toDouble(),
        timestamp:
            DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
        isWandering: map['isWandering'] as bool? ?? false,
      );

  factory GeofenceBreachModel.fromEntity(GeofenceBreach e) =>
      GeofenceBreachModel(
        id: e.id,
        userId: e.userId,
        householdId: e.householdId,
        zoneId: e.zoneId,
        zoneName: e.zoneName,
        type: e.type,
        latitude: e.latitude,
        longitude: e.longitude,
        timestamp: e.timestamp,
        isWandering: e.isWandering,
      );

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'householdId': householdId,
        'zoneId': zoneId,
        'zoneName': zoneName,
        'type': type.name,
        'latitude': latitude,
        'longitude': longitude,
        'timestamp': timestamp.millisecondsSinceEpoch,
        'isWandering': isWandering,
      };
}
