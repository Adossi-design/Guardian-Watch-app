import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/health_anomaly.dart';
import '../entities/health_reading.dart';
import '../repositories/health_repository.dart';

@lazySingleton
class SaveHealthEventUseCase {
  const SaveHealthEventUseCase(this._repository);

  final HealthRepository _repository;

  Future<Either<Failure, void>> saveReading(HealthReading reading) =>
      _repository.saveHealthReading(reading);

  Future<Either<Failure, void>> saveAnomaly(HealthAnomaly anomaly) =>
      _repository.saveAnomaly(anomaly);

  Future<Either<Failure, void>> acknowledgeAnomaly({
    required String anomalyId,
    required String acknowledgedBy,
  }) =>
      _repository.acknowledgeAnomaly(
        anomalyId: anomalyId,
        acknowledgedBy: acknowledgedBy,
      );
}
