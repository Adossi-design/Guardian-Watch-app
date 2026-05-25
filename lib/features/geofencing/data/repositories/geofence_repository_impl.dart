import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/geofence_breach.dart';
import '../../domain/entities/geofence_zone.dart';
import '../../domain/entities/location_reading.dart';
import '../../domain/repositories/geofence_repository.dart';
import '../datasources/geofence_remote_datasource.dart';

@LazySingleton(as: GeofenceRepository)
class GeofenceRepositoryImpl implements GeofenceRepository {
  const GeofenceRepositoryImpl(this._remote);

  final GeofenceRemoteDataSource _remote;

  @override
  Future<Either<Failure, GeofenceZone>> createZone(GeofenceZone zone) async {
    try {
      final created = await _remote.createZone(zone);
      return Right(created);
    } catch (e) {
      return Left(GeofenceFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteZone(String zoneId) async {
    try {
      await _remote.deleteZone(zoneId);
      return const Right(null);
    } catch (e) {
      return Left(GeofenceFailure(e.toString()));
    }
  }

  @override
  Stream<Either<Failure, List<GeofenceZone>>> watchZones(
      String householdId) =>
      _remote.watchZones(householdId).transform(
            StreamTransformer.fromHandlers(
              handleData: (data, sink) =>
                  sink.add(Right<Failure, List<GeofenceZone>>(data)),
              handleError: (e, _, sink) =>
                  sink.add(Left(GeofenceFailure(e.toString()))),
            ),
          );

  @override
  Future<Either<Failure, void>> updateLiveLocation(
      LocationReading location) async {
    try {
      await _remote.updateLiveLocation(location);
      return const Right(null);
    } catch (e) {
      return Left(GeofenceFailure(e.toString()));
    }
  }

  @override
  Stream<Either<Failure, LocationReading?>> watchLiveLocation(
      String userId) =>
      _remote.watchLiveLocation(userId).transform(
            StreamTransformer.fromHandlers(
              handleData: (data, sink) =>
                  sink.add(Right<Failure, LocationReading?>(data)),
              handleError: (e, _, sink) =>
                  sink.add(Left(GeofenceFailure(e.toString()))),
            ),
          );

  @override
  Future<Either<Failure, void>> recordBreach(GeofenceBreach breach) async {
    try {
      await _remote.recordBreach(breach);
      return const Right(null);
    } catch (e) {
      return Left(GeofenceFailure(e.toString()));
    }
  }

  @override
  Stream<Either<Failure, List<GeofenceBreach>>> watchBreaches(
      String householdId) =>
      _remote.watchBreaches(householdId).transform(
            StreamTransformer.fromHandlers(
              handleData: (data, sink) =>
                  sink.add(Right<Failure, List<GeofenceBreach>>(data)),
              handleError: (e, _, sink) =>
                  sink.add(Left(GeofenceFailure(e.toString()))),
            ),
          );
}
