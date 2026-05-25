import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/emergency_incident.dart';
import '../models/emergency_incident_model.dart';

@lazySingleton
class EmergencyRemoteDataSource {
  const EmergencyRemoteDataSource(this._firestore);

  final FirebaseFirestore _firestore;

  static const _collection = 'emergency_incidents';
  static const _uuid = Uuid();

  Future<EmergencyIncident> createIncident({
    required String userId,
    required String householdId,
    required EmergencyTriggerType triggerType,
    required String? userName,
  }) async {
    final id = _uuid.v4();
    final incident = EmergencyIncidentModel(
      id: id,
      userId: userId,
      householdId: householdId,
      triggerType: triggerType,
      // Countdown phase — NOT yet active. Status flips to active when
      // the client-side 30s timer expires (see EmergencyNotifier).
      status: EmergencyStatus.countdown,
      startedAt: DateTime.now(),
      userName: userName,
    );
    await _firestore
        .collection(_collection)
        .doc(id)
        .set(incident.toMap());
    return incident;
  }

  Future<void> updateStatus({
    required String incidentId,
    required EmergencyStatus status,
  }) async {
    final update = <String, dynamic>{'status': status.name};
    if (status == EmergencyStatus.resolved ||
        status == EmergencyStatus.cancelled) {
      update['resolved_at'] = FieldValue.serverTimestamp();
    }
    await _firestore.collection(_collection).doc(incidentId).update(update);
  }

  Future<void> acknowledge({
    required String incidentId,
    required String acknowledgedBy,
  }) =>
      _firestore.collection(_collection).doc(incidentId).update({
        'acknowledged_by': acknowledgedBy,
        'acknowledged_at': FieldValue.serverTimestamp(),
      });

  Stream<List<EmergencyIncident>> watchActiveIncidents({
    required String householdId,
  }) =>
      _firestore
          .collection(_collection)
          .where('household_id', isEqualTo: householdId)
          .where('status', whereIn: [
            EmergencyStatus.active.name,
            EmergencyStatus.countdown.name,
          ])
          .orderBy('started_at', descending: true)
          .snapshots()
          .map((s) => s.docs
              .map((d) => EmergencyIncidentModel.fromMap(d.data()))
              .toList());

  Stream<EmergencyIncident?> watchCurrentIncident({
    required String userId,
  }) =>
      _firestore
          .collection(_collection)
          .where('user_id', isEqualTo: userId)
          .where('status', whereIn: [
            EmergencyStatus.active.name,
            EmergencyStatus.countdown.name,
          ])
          .orderBy('started_at', descending: true)
          .limit(1)
          .snapshots()
          .map((s) => s.docs.isEmpty
              ? null
              : EmergencyIncidentModel.fromMap(s.docs.first.data()));
}
