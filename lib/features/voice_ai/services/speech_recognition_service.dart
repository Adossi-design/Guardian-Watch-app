import 'dart:async';

import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

// Wraps speech_to_text for one-shot query capture.
// Raw audio is processed on-device / via OS speech API — never stored.
// Only the resulting transcript string is kept.
class SpeechRecognitionService {
  final SpeechToText _stt = SpeechToText();
  bool _available = false;

  Future<bool> initialize() async {
    _available = await _stt.initialize(
      onError: (e) {},
      onStatus: (_) {},
    );
    return _available;
  }

  Future<String?> listenOnce({
    Duration timeout = const Duration(seconds: 12),
  }) async {
    if (!_available && !await initialize()) return null;

    final completer = Completer<String?>();

    await _stt.listen(
      onResult: (SpeechRecognitionResult result) {
        if (result.finalResult && !completer.isCompleted) {
          completer.complete(result.recognizedWords.trim());
        }
      },
      listenOptions: SpeechListenOptions(
        listenFor: timeout,
        pauseFor: const Duration(seconds: 3),
        cancelOnError: true,
        listenMode: ListenMode.confirmation,
      ),
    );

    // Fallback timeout — complete with null if STT never fires finalResult
    Future.delayed(timeout + const Duration(seconds: 2), () {
      if (!completer.isCompleted) completer.complete(null);
    });

    return completer.future;
  }

  void stop() => _stt.stop();
  void cancel() => _stt.cancel();
}
