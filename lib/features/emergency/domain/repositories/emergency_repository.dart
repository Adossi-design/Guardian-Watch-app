import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/emergency_incident.dart';

abstract class EmergencyRepository {
  Future<Either<Failure, EmergencyIncident>> createIncident({
    required String userId,
    required String householdId,
    required EmergencyTriggerType triggerType,
    required String? userName,
  });

  Future<Either<Failure, void>> updateStatus({
    required String incidentId,
    required EmergencyStatus status,
  });

  Future<Either<Failure, void>> acknowledge({
    required String incidentId,
    required String acknowledgedBy,
  });

  // Monitor dashboard — stream of ongoing incidents for the household
  Stream<Either<Failure, List<EmergencyIncident>>> watchActiveIncidents({
    required String householdId,
  });

  // Primary dashboard — stream of the user's most recent incident
  Stream<Either<Failure, EmergencyIncident?>> watchCurrentIncident({
    required String userId,
  });
}
