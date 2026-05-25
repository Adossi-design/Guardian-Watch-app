import 'package:equatable/equatable.dart';

enum EmergencyTriggerType {
  sosManual,
  fallDetected,
  healthAnomaly,
  voiceActivated; // Phase 5

  String get displayName => switch (this) {
        sosManual => 'Manual SOS',
        fallDetected => 'Fall Detected',
        healthAnomaly => 'Health Alert',
        voiceActivated => 'Voice Activated',
      };
}

enum EmergencyStatus {
  countdown,
  active,
  resolved,
  cancelled;

  bool get isOngoing => this == active || this == countdown;
}

class EmergencyIncident extends Equatable {
  const EmergencyIncident({
    required this.id,
    required this.userId,
    required this.householdId,
    required this.triggerType,
    required this.status,
    required this.startedAt,
    this.resolvedAt,
    this.acknowledgedBy,
    this.acknowledgedAt,
    this.userName,
    this.notificationsSentCount = 0,
  });

  final String id;
  final String userId;
  final String householdId;
  final EmergencyTriggerType triggerType;
  final EmergencyStatus status;
  final DateTime startedAt;
  final DateTime? resolvedAt;
  final String? acknowledgedBy;
  final DateTime? acknowledgedAt;

  // Included so Cloud Functions can personalise the FCM notification body
  final String? userName;

  // Incremented server-side on each escalation re-notify
  final int notificationsSentCount;

  bool get isAcknowledged => acknowledgedBy != null;

  @override
  List<Object?> get props => [
        id,
        userId,
        householdId,
        triggerType,
        status,
        startedAt,
        resolvedAt,
        acknowledgedBy,
        acknowledgedAt,
        userName,
        notificationsSentCount,
      ];
}
