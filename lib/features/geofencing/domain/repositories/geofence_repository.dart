import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/geofence_breach.dart';
import '../entities/geofence_zone.dart';
import '../entities/location_reading.dart';

abstract class GeofenceRepository {
  Future<Either<Failure, GeofenceZone>> createZone(GeofenceZone zone);
  Future<Either<Failure, void>> deleteZone(String zoneId);
  Stream<Either<Failure, List<GeofenceZone>>> watchZones(String householdId);
  Future<Either<Failure, void>> updateLiveLocation(LocationReading location);
  Stream<Either<Failure, LocationReading?>> watchLiveLocation(String userId);
  Future<Either<Failure, void>> recordBreach(GeofenceBreach breach);
  Stream<Either<Failure, List<GeofenceBreach>>> watchBreaches(
      String householdId);
}
