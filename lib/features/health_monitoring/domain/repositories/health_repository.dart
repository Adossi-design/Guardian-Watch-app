import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/health_anomaly.dart';
import '../entities/health_reading.dart';

abstract class HealthRepository {
  Future<Either<Failure, List<HealthReading>>> fetchRecentReadings({
    required String userId,
    required List<HealthReadingType> types,
    required Duration window,
  });

  Future<Either<Failure, void>> saveHealthReading(HealthReading reading);

  Future<Either<Failure, void>> saveAnomaly(HealthAnomaly anomaly);

  Stream<Either<Failure, List<HealthAnomaly>>> watchAnomalies({
    required String householdId,
    int limit = 20,
  });

  Stream<Either<Failure, List<HealthReading>>> watchRecentReadings({
    required String userId,
    required HealthReadingType type,
    int limit = 10,
  });

  Future<Either<Failure, void>> acknowledgeAnomaly({
    required String anomalyId,
    required String acknowledgedBy,
  });

  Future<bool> hasHealthPermissions(List<HealthReadingType> types);

  Future<bool> requestHealthPermissions(List<HealthReadingType> types);
}
