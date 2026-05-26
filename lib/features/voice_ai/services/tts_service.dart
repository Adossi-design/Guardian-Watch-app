import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  final FlutterTts _tts = FlutterTts();
  bool _initialized = false;

  Future<void> _ensureInitialized() async {
    if (_initialized) return;
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.48);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.05);
    _initialized = true;
  }

  Future<void> speak(String text) async {
    await _ensureInitialized();
    await _tts.speak(text);
  }

  Future<void> stop() => _tts.stop();

  void dispose() {
    _tts.stop();
  }
}
