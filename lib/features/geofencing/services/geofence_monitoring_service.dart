import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:uuid/uuid.dart';
import '../domain/entities/geofence_breach.dart';
import '../domain/entities/geofence_zone.dart';
import '../domain/entities/location_reading.dart';

typedef BreachCallback = void Function(GeofenceBreach breach);

// 3-tier monitoring:
//   1. Location update → RTDB (every GPS fix, ~30 s average)
//   2. Zone boundary check → record breach on each state transition
//   3. Wandering detection → if outside ALL zones for > 10 min, fire once per episode
class GeofenceMonitoringService {
  GeofenceMonitoringService({
    required this.userId,
    required this.householdId,
    required this.onLocationUpdate,
    required this.onBreach,
    required this.onWanderingDetected,
  });

  final String userId;
  final String householdId;
  final void Function(LocationReading) onLocationUpdate;
  final BreachCallback onBreach;
  final VoidCallback onWanderingDetected;

  static const _wanderingThreshold = Duration(minutes: 10);
  static const _uuid = Uuid();

  StreamSubscription<Position>? _sub;
  List<GeofenceZone> _zones = [];

  // zoneId → was user inside on last check
  final Map<String, bool> _zoneStates = {};

  // When user first left all zones; null while inside at least one zone
  DateTime? _outsideAllZonesSince;
  bool _wanderingFired = false;

  void start(List<GeofenceZone> zones) {
    _zones = zones;
    _sub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // metres — avoid GPS noise
      ),
    ).listen(_onPosition, onError: (_) {});
  }

  void updateZones(List<GeofenceZone> zones) {
    _zones = zones;
    // Remove state entries for zones that no longer exist
    final ids = zones.map((z) => z.id).toSet();
    _zoneStates.removeWhere((id, _) => !ids.contains(id));
  }

  void stop() {
    _sub?.cancel();
    _sub = null;
    _zoneStates.clear();
    _outsideAllZonesSince = null;
    _wanderingFired = false;
  }

  void dispose() => stop();

  void _onPosition(Position pos) {
    final reading = LocationReading(
      userId: userId,
      latitude: pos.latitude,
      longitude: pos.longitude,
      accuracyMeters: pos.accuracy,
      timestamp: pos.timestamp,
    );
    onLocationUpdate(reading);
    _checkZones(reading);
  }

  void _checkZones(LocationReading loc) {
    bool insideAny = false;

    for (final zone in _zones) {
      final dist = _haversine(
        loc.latitude, loc.longitude,
        zone.centerLat, zone.centerLng,
      );
      final isInside = dist <= zone.radiusMeters;
      if (isInside) insideAny = true;

      final wasInside = _zoneStates[zone.id];

      if (wasInside == null) {
        // First reading for this zone — initialise silently
        _zoneStates[zone.id] = isInside;
        continue;
      }

      if (isInside == wasInside) continue; // no transition

      _zoneStates[zone.id] = isInside;

      final breach = GeofenceBreach(
        id: _uuid.v4(),
        userId: userId,
        householdId: householdId,
        zoneId: zone.id,
        zoneName: zone.name,
        type: isInside ? BreachType.enter : BreachType.exit,
        latitude: loc.latitude,
        longitude: loc.longitude,
        timestamp: loc.timestamp,
      );
      onBreach(breach);
    }

    // Wandering detection
    final now = DateTime.now();
    if (insideAny) {
      _outsideAllZonesSince = null;
      _wanderingFired = false;
    } else if (_zones.isNotEmpty) {
      _outsideAllZonesSince ??= now;
      if (!_wanderingFired &&
          now.difference(_outsideAllZonesSince!) >= _wanderingThreshold) {
        _wanderingFired = true;
        onWanderingDetected();
      }
    }
  }

  // Haversine great-circle distance in metres
  static double _haversine(
      double lat1, double lng1, double lat2, double lng2) {
    const r = 6371000.0;
    final dLat = _rad(lat2 - lat1);
    final dLng = _rad(lng2 - lng1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_rad(lat1)) * cos(_rad(lat2)) * sin(dLng / 2) * sin(dLng / 2);
    return r * 2 * atan2(sqrt(a), sqrt(1 - a));
  }

  static double _rad(double deg) => deg * pi / 180;
}
