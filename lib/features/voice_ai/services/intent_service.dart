import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

// Sends the user's transcript to OpenAI GPT-4o and returns a text response.
//
// Security guarantees (per spec):
//   • API key stored ONLY in flutter_secure_storage — never hardcoded.
//   • Raw audio is NEVER sent — only the transcript string.
//   • Raw health data is NEVER sent — only a structured text summary
//     (e.g. "HR: 72 bpm, SpO2: 98%").
class IntentService {
  static const _openAiKeyStorageKey = 'openai_api_key';
  static const _endpoint =
      'https://api.openai.com/v1/chat/completions';

  final FlutterSecureStorage _storage;

  IntentService({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  Future<void> saveApiKey(String key) =>
      _storage.write(key: _openAiKeyStorageKey, value: key.trim());

  Future<bool> hasApiKey() async {
    final k = await _storage.read(key: _openAiKeyStorageKey);
    return k != null && k.isNotEmpty;
  }

  Future<String> query({
    required String transcript,
    String healthContext = '',
  }) async {
    final apiKey = await _storage.read(key: _openAiKeyStorageKey);
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('OpenAI API key not configured.');
    }

    final messages = <Map<String, String>>[
      {'role': 'system', 'content': _systemPrompt},
      if (healthContext.isNotEmpty)
        {
          'role': 'system',
          'content':
              'Current health summary (structured text only): $healthContext',
        },
      {'role': 'user', 'content': transcript},
    ];

    final res = await http
        .post(
          Uri.parse(_endpoint),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $apiKey',
          },
          body: jsonEncode({
            'model': 'gpt-4o',
            'messages': messages,
            'max_tokens': 160,
            'temperature': 0.7,
          }),
        )
        .timeout(const Duration(seconds: 20));

    if (res.statusCode != 200) {
      throw Exception('OpenAI responded with ${res.statusCode}');
    }

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    return (data['choices'] as List).first['message']['content'] as String;
  }

  static const _systemPrompt =
      'You are Hey Guardian, a compassionate AI health assistant built into '
      'a personal safety app for elderly users and their caregivers. '
      'Keep every response to 2–3 sentences, clear and reassuring. '
      'Never diagnose medical conditions. '
      'For anything serious, advise the user to call their doctor or emergency services.';
}
