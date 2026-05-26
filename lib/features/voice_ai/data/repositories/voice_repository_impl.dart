import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/voice_session.dart';
import '../../domain/repositories/voice_repository.dart';
import '../datasources/voice_remote_datasource.dart';

@LazySingleton(as: VoiceRepository)
class VoiceRepositoryImpl implements VoiceRepository {
  const VoiceRepositoryImpl(this._remote);

  final VoiceRemoteDataSource _remote;

  @override
  Future<Either<Failure, void>> saveSession(VoiceSession session) async {
    try {
      await _remote.saveSession(session);
      return const Right(null);
    } catch (e) {
      return Left(VoiceAIFailure(e.toString()));
    }
  }

  @override
  Stream<Either<Failure, List<VoiceSession>>> watchRecentSessions(
          String userId) =>
      _remote.watchRecentSessions(userId).transform(
            StreamTransformer.fromHandlers(
              handleData: (data, sink) =>
                  sink.add(Right<Failure, List<VoiceSession>>(data)),
              handleError: (e, _, sink) =>
                  sink.add(Left(VoiceAIFailure(e.toString()))),
            ),
          );
}
