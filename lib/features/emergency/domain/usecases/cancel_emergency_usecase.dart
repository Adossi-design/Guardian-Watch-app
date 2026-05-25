import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/emergency_incident.dart';
import '../repositories/emergency_repository.dart';

@lazySingleton
class CancelEmergencyUseCase {
  const CancelEmergencyUseCase(this._repository);

  final EmergencyRepository _repository;

  Future<Either<Failure, void>> call(String incidentId) =>
      _repository.updateStatus(
        incidentId: incidentId,
        status: EmergencyStatus.cancelled,
      );
}
