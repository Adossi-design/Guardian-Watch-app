import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/voice_session.dart';
import '../models/voice_session_model.dart';

@lazySingleton
class VoiceRemoteDataSource {
  const VoiceRemoteDataSource(this._firestore);

  final FirebaseFirestore _firestore;

  Future<void> saveSession(VoiceSession session) async {
    final model = VoiceSessionModel.fromEntity(session);
    await _firestore
        .collection('voice_sessions')
        .doc(session.id)
        .set(model.toMap());
  }

  Stream<List<VoiceSession>> watchRecentSessions(String userId) => _firestore
      .collection('voice_sessions')
      .where('userId', isEqualTo: userId)
      .orderBy('timestamp', descending: true)
      .limit(20)
      .snapshots()
      .map((snap) => snap.docs
          .map((d) => VoiceSessionModel.fromMap(d.id, d.data()))
          .toList());
}
