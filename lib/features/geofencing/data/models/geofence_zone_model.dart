import '../../domain/entities/geofence_zone.dart';

class GeofenceZoneModel extends GeofenceZone {
  const GeofenceZoneModel({
    required super.id,
    required super.householdId,
    required super.name,
    required super.centerLat,
    required super.centerLng,
    required super.radiusMeters,
    required super.createdAt,
    required super.createdBy,
  });

  factory GeofenceZoneModel.fromMap(String id, Map<String, dynamic> map) =>
      GeofenceZoneModel(
        id: id,
        householdId: map['householdId'] as String,
        name: map['name'] as String,
        centerLat: (map['centerLat'] as num).toDouble(),
        centerLng: (map['centerLng'] as num).toDouble(),
        radiusMeters: (map['radiusMeters'] as num).toDouble(),
        createdAt:
            DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
        createdBy: map['createdBy'] as String,
      );

  factory GeofenceZoneModel.fromEntity(GeofenceZone e) => GeofenceZoneModel(
        id: e.id,
        householdId: e.householdId,
        name: e.name,
        centerLat: e.centerLat,
        centerLng: e.centerLng,
        radiusMeters: e.radiusMeters,
        createdAt: e.createdAt,
        createdBy: e.createdBy,
      );

  Map<String, dynamic> toMap() => {
        'householdId': householdId,
        'name': name,
        'centerLat': centerLat,
        'centerLng': centerLng,
        'radiusMeters': radiusMeters,
        'createdAt': createdAt.millisecondsSinceEpoch,
        'createdBy': createdBy,
      };
}
