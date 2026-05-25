import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/emergency_incident.dart';

class EmergencyIncidentModel extends EmergencyIncident {
  const EmergencyIncidentModel({
    required super.id,
    required super.userId,
    required super.householdId,
    required super.triggerType,
    required super.status,
    required super.startedAt,
    super.resolvedAt,
    super.acknowledgedBy,
    super.acknowledgedAt,
    super.userName,
    super.notificationsSentCount,
  });

  factory EmergencyIncidentModel.fromMap(Map<String, dynamic> map) =>
      EmergencyIncidentModel(
        id: map['id'] as String,
        userId: map['user_id'] as String,
        householdId: map['household_id'] as String,
        triggerType: EmergencyTriggerType.values.byName(
          map['trigger_type'] as String,
        ),
        status: EmergencyStatus.values.byName(map['status'] as String),
        startedAt: (map['started_at'] as Timestamp).toDate(),
        resolvedAt: map['resolved_at'] != null
            ? (map['resolved_at'] as Timestamp).toDate()
            : null,
        acknowledgedBy: map['acknowledged_by'] as String?,
        acknowledgedAt: map['acknowledged_at'] != null
            ? (map['acknowledged_at'] as Timestamp).toDate()
            : null,
        userName: map['user_name'] as String?,
        notificationsSentCount:
            (map['notifications_sent_count'] as int?) ?? 0,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'user_id': userId,
        'household_id': householdId,
        'trigger_type': triggerType.name,
        'status': status.name,
        'started_at': Timestamp.fromDate(startedAt),
        'resolved_at':
            resolvedAt != null ? Timestamp.fromDate(resolvedAt!) : null,
        'acknowledged_by': acknowledgedBy,
        'acknowledged_at': acknowledgedAt != null
            ? Timestamp.fromDate(acknowledgedAt!)
            : null,
        'user_name': userName,
        'notifications_sent_count': notificationsSentCount,
      };

  factory EmergencyIncidentModel.fromEntity(EmergencyIncident entity) =>
      EmergencyIncidentModel(
        id: entity.id,
        userId: entity.userId,
        householdId: entity.householdId,
        triggerType: entity.triggerType,
        status: entity.status,
        startedAt: entity.startedAt,
        resolvedAt: entity.resolvedAt,
        acknowledgedBy: entity.acknowledgedBy,
        acknowledgedAt: entity.acknowledgedAt,
        userName: entity.userName,
        notificationsSentCount: entity.notificationsSentCount,
      );
}
