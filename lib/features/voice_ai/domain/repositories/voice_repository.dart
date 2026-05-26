import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/voice_session.dart';

abstract class VoiceRepository {
  Future<Either<Failure, void>> saveSession(VoiceSession session);
  Stream<Either<Failure, List<VoiceSession>>> watchRecentSessions(
      String userId);
}
