import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../repositories/geofence_repository.dart';

@lazySingleton
class DeleteGeofenceZoneUseCase {
  const DeleteGeofenceZoneUseCase(this._repo);

  final GeofenceRepository _repo;

  Future<Either<Failure, void>> call(String zoneId) =>
      _repo.deleteZone(zoneId);
}
