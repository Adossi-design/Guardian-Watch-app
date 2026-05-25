import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/health_anomaly.dart';
import '../../domain/entities/health_reading.dart';
import '../../domain/repositories/health_repository.dart';
import '../datasources/health_local_datasource.dart';
import '../datasources/health_remote_datasource.dart';

@LazySingleton(as: HealthRepository)
class HealthRepositoryImpl implements HealthRepository {
  const HealthRepositoryImpl(this._local, this._remote);

  final HealthLocalDataSource _local;
  final HealthRemoteDataSource _remote;

  @override
  Future<Either<Failure, List<HealthReading>>> fetchRecentReadings({
    required String userId,
    required List<HealthReadingType> types,
    required Duration window,
  }) async {
    try {
      final readings = await _local.fetchReadings(
        userId: userId,
        types: types,
        window: window,
      );
      return Right(readings);
    } on PermissionException {
      return const Left(PermissionFailure('Health permissions not granted'));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> saveHealthReading(HealthReading reading) async {
    try {
      await _remote.saveReading(reading);
      return const Right(null);
    } on EncryptionException catch (e) {
      return Left(EncryptionFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> saveAnomaly(HealthAnomaly anomaly) async {
    try {
      await _remote.saveAnomaly(anomaly);
      return const Right(null);
    } on EncryptionException catch (e) {
      return Left(EncryptionFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Stream<Either<Failure, List<HealthAnomaly>>> watchAnomalies({
    required String householdId,
    int limit = 20,
  }) =>
      _remote
          .watchAnomalies(householdId: householdId, limit: limit)
          .transform(
            StreamTransformer.fromHandlers(
              handleData: (data, sink) =>
                  sink.add(Right<Failure, List<HealthAnomaly>>(data)),
              handleError: (e, _, sink) =>
                  sink.add(Left(ServerFailure(e.toString()))),
            ),
          );

  @override
  Stream<Either<Failure, List<HealthReading>>> watchRecentReadings({
    required String userId,
    required HealthReadingType type,
    int limit = 10,
  }) =>
      _remote
          .watchRecentReadings(userId: userId, type: type, limit: limit)
          .transform(
            StreamTransformer.fromHandlers(
              handleData: (data, sink) =>
                  sink.add(Right<Failure, List<HealthReading>>(data)),
              handleError: (e, _, sink) =>
                  sink.add(Left(ServerFailure(e.toString()))),
            ),
          );

  @override
  Future<Either<Failure, void>> acknowledgeAnomaly({
    required String anomalyId,
    required String acknowledgedBy,
  }) async {
    try {
      await _remote.acknowledgeAnomaly(
        anomalyId: anomalyId,
        acknowledgedBy: acknowledgedBy,
      );
      return const Right(null);
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<bool> hasHealthPermissions(List<HealthReadingType> types) =>
      _local.hasPermissions(types);

  @override
  Future<bool> requestHealthPermissions(List<HealthReadingType> types) =>
      _local.requestPermissions(types);
}
