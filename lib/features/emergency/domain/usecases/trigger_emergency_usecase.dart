import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/emergency_incident.dart';
import '../repositories/emergency_repository.dart';

@lazySingleton
class TriggerEmergencyUseCase {
  const TriggerEmergencyUseCase(this._repository);

  final EmergencyRepository _repository;

  Future<Either<Failure, EmergencyIncident>> call({
    required String userId,
    required String householdId,
    required EmergencyTriggerType triggerType,
    required String? userName,
  }) =>
      _repository.createIncident(
        userId: userId,
        householdId: householdId,
        triggerType: triggerType,
        userName: userName,
      );
}
