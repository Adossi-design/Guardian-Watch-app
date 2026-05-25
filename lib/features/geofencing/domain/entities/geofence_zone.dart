import 'package:equatable/equatable.dart';

class GeofenceZone extends Equatable {
  const GeofenceZone({
    required this.id,
    required this.householdId,
    required this.name,
    required this.centerLat,
    required this.centerLng,
    required this.radiusMeters,
    required this.createdAt,
    required this.createdBy,
  });

  final String id;
  final String householdId;
  final String name;
  final double centerLat;
  final double centerLng;
  final double radiusMeters;
  final DateTime createdAt;
  final String createdBy;

  @override
  List<Object?> get props => [id, householdId, name, centerLat, centerLng,
      radiusMeters, createdAt, createdBy];
}
