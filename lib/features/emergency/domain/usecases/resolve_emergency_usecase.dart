import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/emergency_incident.dart';
import '../repositories/emergency_repository.dart';

@lazySingleton
class ResolveEmergencyUseCase {
  const ResolveEmergencyUseCase(this._repository);

  final EmergencyRepository _repository;

  Future<Either<Failure, void>> resolve(String incidentId) =>
      _repository.updateStatus(
        incidentId: incidentId,
        status: EmergencyStatus.resolved,
      );

  Future<Either<Failure, void>> acknowledge({
    required String incidentId,
    required String acknowledgedBy,
  }) =>
      _repository.acknowledge(
        incidentId: incidentId,
        acknowledgedBy: acknowledgedBy,
      );
}
