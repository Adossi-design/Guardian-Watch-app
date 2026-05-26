import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';
import '../../../auth/presentation/bloc/auth_provider.dart';
import '../../../health_monitoring/domain/entities/health_reading.dart';
import '../../../health_monitoring/presentation/bloc/health_provider.dart';
import '../../domain/entities/voice_session.dart';
import '../../domain/repositories/voice_repository.dart';
import '../../domain/usecases/save_voice_session_usecase.dart';
import '../../services/home_widget_service.dart';
import '../../services/intent_service.dart';
import '../../services/speech_recognition_service.dart';
import '../../services/tts_service.dart';
import '../../services/wake_word_service.dart';

// ── State ─────────────────────────────────────────────────────────────────────

sealed class VoiceAIState {
  const VoiceAIState();
}

final class VoiceSetupRequired extends VoiceAIState {
  const VoiceSetupRequired();
}

final class VoiceIdle extends VoiceAIState {
  const VoiceIdle();
}

final class VoiceListeningWakeWord extends VoiceAIState {
  const VoiceListeningWakeWord();
}

final class VoiceCapturingQuery extends VoiceAIState {
  const VoiceCapturingQuery();
}

final class VoiceProcessing extends VoiceAIState {
  const VoiceProcessing(this.transcript);
  final String transcript;
}

final class VoiceResponding extends VoiceAIState {
  const VoiceResponding({required this.transcript, required this.response});
  final String transcript;
  final String response;
}

final class VoiceError extends VoiceAIState {
  const VoiceError(this.message);
  final String message;
}

// ── Notifier ──────────────────────────────────────────────────────────────────

class VoiceNotifier extends AsyncNotifier<VoiceAIState> {
  static const _picoKeyStorageKey = 'picovoice_access_key';
  static const _uuid = Uuid();

  late final IntentService _intent;
  late final SpeechRecognitionService _stt;
  late final TtsService _tts;
  WakeWordService? _wakeWord;

  @override
  Future<VoiceAIState> build() async {
    _intent = IntentService();
    _stt = SpeechRecognitionService();
    _tts = TtsService();

    ref.onDispose(() {
      _wakeWord?.dispose();
      _tts.dispose();
    });

    final hasOpenAIKey = await _intent.hasApiKey();
    if (!hasOpenAIKey) return const VoiceSetupRequired();

    final picoKey = await const FlutterSecureStorage()
        .read(key: _picoKeyStorageKey);

    if (picoKey != null && picoKey.isNotEmpty) {
      _wakeWord = WakeWordService(onWakeWordDetected: _onWakeWordDetected);
      await _wakeWord!.start(picoKey);
      return const VoiceListeningWakeWord();
    }

    // No Porcupine key — still functional via manual button
    return const VoiceIdle();
  }

  // ── Public API ──────────────────────────────────────────────────────────────

  Future<void> startListening() async {
    final current = state.valueOrNull;
    if (current is VoiceCapturingQuery || current is VoiceProcessing) return;
    state = const AsyncData(VoiceCapturingQuery());
    await _captureAndProcess(wakeWordTriggered: false);
  }

  Future<void> saveOpenAIKey(String key) async {
    await _intent.saveApiKey(key);
    ref.invalidateSelf();
  }

  Future<void> savePicovoiceKey(String key) async {
    await const FlutterSecureStorage()
        .write(key: _picoKeyStorageKey, value: key.trim());
    ref.invalidateSelf();
  }

  // ── Private pipeline ────────────────────────────────────────────────────────

  void _onWakeWordDetected() {
    state = const AsyncData(VoiceCapturingQuery());
    _captureAndProcess(wakeWordTriggered: true);
  }

  Future<void> _captureAndProcess({required bool wakeWordTriggered}) async {
    final transcript = await _stt.listenOnce();

    if (transcript == null || transcript.isEmpty) {
      _returnToListening();
      return;
    }

    state = AsyncData(VoiceProcessing(transcript));

    try {
      final response = await _intent.query(
        transcript: transcript,
        healthContext: _buildHealthContext(),
      );

      state = AsyncData(VoiceResponding(
        transcript: transcript,
        response: response,
      ));

      // Speak the response — raw audio never stored
      await _tts.speak(response);

      // Persist transcript + response to Firestore (never audio)
      final user = ref.read(currentUserProvider);
      if (user != null) {
        await ref.read(saveVoiceSessionUseCaseProvider).call(
              VoiceSession(
                id: _uuid.v4(),
                userId: user.uid,
                transcript: transcript,
                response: response,
                timestamp: DateTime.now(),
                wasWakeWordTriggered: wakeWordTriggered,
              ),
            );
      }

      // Update home screen widget
      await HomeWidgetService.updateLastResponse(
        response: response,
        timestamp: DateTime.now(),
      );

      await Future.delayed(const Duration(seconds: 2));
      _returnToListening();
    } catch (e) {
      state = AsyncData(VoiceError(e.toString()));
      await Future.delayed(const Duration(seconds: 3));
      _returnToListening();
    }
  }

  void _returnToListening() {
    if (_wakeWord != null) {
      state = const AsyncData(VoiceListeningWakeWord());
    } else {
      state = const AsyncData(VoiceIdle());
    }
  }

  // Structured text summary — never sends raw health data to external APIs
  String _buildHealthContext() {
    final healthState =
        ref.read(healthNotifierProvider).valueOrNull;
    if (healthState is! HealthData) return '';

    final readings = healthState.latestReadings;
    final parts = <String>[];

    final hr = readings[HealthReadingType.heartRate];
    if (hr != null) parts.add('HR: ${hr.value.toInt()} bpm');

    final spo2 = readings[HealthReadingType.bloodOxygen];
    if (spo2 != null) parts.add('SpO2: ${spo2.value.toInt()}%');

    final steps = readings[HealthReadingType.steps];
    if (steps != null) parts.add('Steps: ${steps.value.toInt()}');

    if (healthState.activeAnomaly != null) {
      parts.add('Alert: ${healthState.activeAnomaly!.type.displayName}');
    }

    return parts.join(', ');
  }
}

// ── Providers ─────────────────────────────────────────────────────────────────

final voiceNotifierProvider =
    AsyncNotifierProvider<VoiceNotifier, VoiceAIState>(VoiceNotifier.new);

// DI bridge providers
final voiceRepositoryProvider = Provider<VoiceRepository>(
  (_) => throw UnimplementedError('Override in ProviderScope'),
);

final saveVoiceSessionUseCaseProvider = Provider<SaveVoiceSessionUseCase>(
  (_) => throw UnimplementedError('Override in ProviderScope'),
);
