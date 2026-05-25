import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/geofence_zone.dart';
import '../repositories/geofence_repository.dart';

@lazySingleton
class CreateGeofenceZoneUseCase {
  const CreateGeofenceZoneUseCase(this._repo);

  final GeofenceRepository _repo;

  Future<Either<Failure, GeofenceZone>> call(GeofenceZone zone) =>
      _repo.createZone(zone);
}
