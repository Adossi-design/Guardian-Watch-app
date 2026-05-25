import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/health_reading.dart';
import '../repositories/health_repository.dart';

@lazySingleton
class FetchHealthDataUseCase {
  const FetchHealthDataUseCase(this._repository);

  final HealthRepository _repository;

  Future<Either<Failure, List<HealthReading>>> call(FetchHealthParams params) =>
      _repository.fetchRecentReadings(
        userId: params.userId,
        types: params.types,
        window: params.window,
      );
}

class FetchHealthParams extends Equatable {
  const FetchHealthParams({
    required this.userId,
    required this.types,
    required this.window,
  });

  final String userId;
  final List<HealthReadingType> types;
  final Duration window;

  @override
  List<Object?> get props => [userId, types, window];
}
