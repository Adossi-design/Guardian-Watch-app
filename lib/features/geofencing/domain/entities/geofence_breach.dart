import 'package:equatable/equatable.dart';

enum BreachType {
  exit,
  enter;

  String get displayName => switch (this) {
        BreachType.exit => 'Left zone',
        BreachType.enter => 'Entered zone',
      };
}

class GeofenceBreach extends Equatable {
  const GeofenceBreach({
    required this.id,
    required this.userId,
    required this.householdId,
    required this.zoneId,
    required this.zoneName,
    required this.type,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    this.isWandering = false,
  });

  final String id;
  final String userId;
  final String householdId;
  final String zoneId;
  final String zoneName;
  final BreachType type;
  final double latitude;
  final double longitude;
  final DateTime timestamp;

  // True when the user has been outside ALL zones for > 10 minutes
  final bool isWandering;

  @override
  List<Object?> get props => [
        id, userId, householdId, zoneId, zoneName, type,
        latitude, longitude, timestamp, isWandering,
      ];
}
