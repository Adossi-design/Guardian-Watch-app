import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/geofence_breach.dart';
import '../repositories/geofence_repository.dart';

@lazySingleton
class RecordBreachUseCase {
  const RecordBreachUseCase(this._repo);

  final GeofenceRepository _repo;

  Future<Either<Failure, void>> call(GeofenceBreach breach) =>
      _repo.recordBreach(breach);
}
