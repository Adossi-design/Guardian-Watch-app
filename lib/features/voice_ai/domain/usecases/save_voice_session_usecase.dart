import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/voice_session.dart';
import '../repositories/voice_repository.dart';

@lazySingleton
class SaveVoiceSessionUseCase {
  const SaveVoiceSessionUseCase(this._repo);

  final VoiceRepository _repo;

  Future<Either<Failure, void>> call(VoiceSession session) =>
      _repo.saveSession(session);
}
