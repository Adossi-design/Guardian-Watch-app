import 'package:equatable/equatable.dart';

class VoiceSession extends Equatable {
  const VoiceSession({
    required this.id,
    required this.userId,
    required this.transcript,
    required this.response,
    required this.timestamp,
    this.wasWakeWordTriggered = false,
  });

  final String id;
  final String userId;
  final String transcript; // user's spoken question — text only, never audio
  final String response;   // AI response text
  final DateTime timestamp;
  final bool wasWakeWordTriggered;

  @override
  List<Object?> get props =>
      [id, userId, transcript, response, timestamp, wasWakeWordTriggered];
}
