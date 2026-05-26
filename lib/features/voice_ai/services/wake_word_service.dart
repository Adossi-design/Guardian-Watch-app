import 'package:flutter/foundation.dart';
import 'package:porcupine_flutter/porcupine.dart';
import 'package:porcupine_flutter/porcupine_error.dart';
import 'package:porcupine_flutter/porcupine_manager.dart';

// Wraps Picovoice Porcupine for on-device "Hey Guardian" wake word detection.
//
// Development: uses the built-in PORCUPINE keyword (say "porcupine" to test).
// Production:  replace with a custom .ppn model trained at console.picovoice.ai.
//              Drop the model file into assets/models/ and update _keywordPath.
//
// Audio NEVER leaves the device — Porcupine runs entirely on-device.
class WakeWordService {
  WakeWordService({required this.onWakeWordDetected});

  final VoidCallback onWakeWordDetected;

  PorcupineManager? _manager;
  bool _running = false;

  Future<void> start(String accessKey) async {
    if (_running) return;
    try {
      _manager = await PorcupineManager.fromBuiltInKeywords(
        accessKey,
        [BuiltInKeyword.PORCUPINE],
        _onWakeWord,
        errorCallback: (PorcupineException e) =>
            debugPrint('WakeWord error: $e'),
      );
      await _manager!.start();
      _running = true;
    } on PorcupineInvalidArgumentException catch (e) {
      debugPrint('Porcupine invalid argument: $e');
    } on PorcupineActivationException catch (e) {
      debugPrint('Porcupine activation error (check AccessKey): $e');
    } on PorcupineException catch (e) {
      debugPrint('Porcupine error: $e');
    }
  }

  Future<void> stop() async {
    if (!_running) return;
    await _manager?.stop();
    await _manager?.delete();
    _manager = null;
    _running = false;
  }

  void dispose() {
    stop();
  }

  void _onWakeWord(int keywordIndex) {
    if (keywordIndex >= 0) onWakeWordDetected();
  }
}
