import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/geofence_breach.dart';
import '../../domain/entities/geofence_zone.dart';
import '../../domain/entities/location_reading.dart';
import '../models/geofence_breach_model.dart';
import '../models/geofence_zone_model.dart';
import '../models/location_reading_model.dart';

@lazySingleton
class GeofenceRemoteDataSource {
  GeofenceRemoteDataSource(this._firestore) : _rtdb = FirebaseDatabase.instance;

  final FirebaseFirestore _firestore;
  final FirebaseDatabase _rtdb;

  static const _uuid = Uuid();

  // ── Zones (Firestore) ─────────────────────────────────────────────────────

  Future<GeofenceZone> createZone(GeofenceZone zone) async {
    final id = zone.id.isEmpty ? _uuid.v4() : zone.id;
    final model = GeofenceZoneModel.fromEntity(
      GeofenceZone(
        id: id,
        householdId: zone.householdId,
        name: zone.name,
        centerLat: zone.centerLat,
        centerLng: zone.centerLng,
        radiusMeters: zone.radiusMeters,
        createdAt: zone.createdAt,
        createdBy: zone.createdBy,
      ),
    );
    await _firestore.collection('geofence_zones').doc(id).set(model.toMap());
    return model;
  }

  Future<void> deleteZone(String zoneId) =>
      _firestore.collection('geofence_zones').doc(zoneId).delete();

  Stream<List<GeofenceZone>> watchZones(String householdId) => _firestore
      .collection('geofence_zones')
      .where('householdId', isEqualTo: householdId)
      .orderBy('createdAt', descending: false)
      .snapshots()
      .map((snap) => snap.docs
          .map((d) => GeofenceZoneModel.fromMap(d.id, d.data()))
          .toList());

  // ── Live location (Realtime Database) ────────────────────────────────────

  Future<void> updateLiveLocation(LocationReading location) async {
    final model = LocationReadingModel.fromEntity(location);
    await _rtdb
        .ref('live_locations/${location.userId}')
        .set(model.toMap());
  }

  Stream<LocationReading?> watchLiveLocation(String userId) =>
      _rtdb.ref('live_locations/$userId').onValue.map((event) {
        final data = event.snapshot.value;
        if (data == null) return null;
        return LocationReadingModel.fromMap(
            userId, data as Map<dynamic, dynamic>);
      });

  // ── Breach events (Firestore) ─────────────────────────────────────────────

  Future<void> recordBreach(GeofenceBreach breach) async {
    final id = breach.id.isEmpty ? _uuid.v4() : breach.id;
    final model = GeofenceBreachModel.fromEntity(
      GeofenceBreach(
        id: id,
        userId: breach.userId,
        householdId: breach.householdId,
        zoneId: breach.zoneId,
        zoneName: breach.zoneName,
        type: breach.type,
        latitude: breach.latitude,
        longitude: breach.longitude,
        timestamp: breach.timestamp,
        isWandering: breach.isWandering,
      ),
    );
    await _firestore
        .collection('geofence_breaches')
        .doc(id)
        .set(model.toMap());
  }

  Stream<List<GeofenceBreach>> watchBreaches(String householdId) => _firestore
      .collection('geofence_breaches')
      .where('householdId', isEqualTo: householdId)
      .orderBy('timestamp', descending: true)
      .limit(50)
      .snapshots()
      .map((snap) => snap.docs
          .map((d) => GeofenceBreachModel.fromMap(d.id, d.data()))
          .toList());
}
