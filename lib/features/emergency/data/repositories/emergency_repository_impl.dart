import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/emergency_incident.dart';
import '../../domain/repositories/emergency_repository.dart';
import '../datasources/emergency_remote_datasource.dart';

@LazySingleton(as: EmergencyRepository)
class EmergencyRepositoryImpl implements EmergencyRepository {
  const EmergencyRepositoryImpl(this._remote);

  final EmergencyRemoteDataSource _remote;

  @override
  Future<Either<Failure, EmergencyIncident>> createIncident({
    required String userId,
    required String householdId,
    required EmergencyTriggerType triggerType,
    required String? userName,
  }) async {
    try {
      final incident = await _remote.createIncident(
        userId: userId,
        householdId: householdId,
        triggerType: triggerType,
        userName: userName,
      );
      return Right(incident);
    } catch (e) {
      return Left(EmergencyFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateStatus({
    required String incidentId,
    required EmergencyStatus status,
  }) async {
    try {
      await _remote.updateStatus(incidentId: incidentId, status: status);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> acknowledge({
    required String incidentId,
    required String acknowledgedBy,
  }) async {
    try {
      await _remote.acknowledge(
        incidentId: incidentId,
        acknowledgedBy: acknowledgedBy,
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Stream<Either<Failure, List<EmergencyIncident>>> watchActiveIncidents({
    required String householdId,
  }) =>
      _remote
          .watchActiveIncidents(householdId: householdId)
          .transform(
            StreamTransformer.fromHandlers(
              handleData: (data, sink) =>
                  sink.add(Right<Failure, List<EmergencyIncident>>(data)),
              handleError: (e, _, sink) =>
                  sink.add(Left(ServerFailure(e.toString()))),
            ),
          );

  @override
  Stream<Either<Failure, EmergencyIncident?>> watchCurrentIncident({
    required String userId,
  }) =>
      _remote
          .watchCurrentIncident(userId: userId)
          .transform(
            StreamTransformer.fromHandlers(
              handleData: (data, sink) =>
                  sink.add(Right<Failure, EmergencyIncident?>(data)),
              handleError: (e, _, sink) =>
                  sink.add(Left(ServerFailure(e.toString()))),
            ),
          );
}
