import '../../domain/entities/voice_session.dart';

class VoiceSessionModel extends VoiceSession {
  const VoiceSessionModel({
    required super.id,
    required super.userId,
    required super.transcript,
    required super.response,
    required super.timestamp,
    super.wasWakeWordTriggered,
  });

  factory VoiceSessionModel.fromMap(String id, Map<String, dynamic> map) =>
      VoiceSessionModel(
        id: id,
        userId: map['userId'] as String,
        transcript: map['transcript'] as String,
        response: map['response'] as String,
        timestamp:
            DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
        wasWakeWordTriggered: map['wasWakeWordTriggered'] as bool? ?? false,
      );

  factory VoiceSessionModel.fromEntity(VoiceSession e) => VoiceSessionModel(
        id: e.id,
        userId: e.userId,
        transcript: e.transcript,
        response: e.response,
        timestamp: e.timestamp,
        wasWakeWordTriggered: e.wasWakeWordTriggered,
      );

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'transcript': transcript,
        'response': response,
        'timestamp': timestamp.millisecondsSinceEpoch,
        'wasWakeWordTriggered': wasWakeWordTriggered,
      };
}
