import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/location_reading.dart';
import '../repositories/geofence_repository.dart';

@lazySingleton
class UpdateLocationUseCase {
  const UpdateLocationUseCase(this._repo);

  final GeofenceRepository _repo;

  Future<Either<Failure, void>> call(LocationReading location) =>
      _repo.updateLiveLocation(location);
}
