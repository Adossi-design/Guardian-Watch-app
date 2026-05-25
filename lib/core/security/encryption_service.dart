import 'dart:convert';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart' as enc;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import '../error/exceptions.dart';

// AES-256 encryption for medical data before any Firestore write.
// Key is per-user and stored in platform secure storage (Keychain / Keystore).
@lazySingleton
class EncryptionService {
  EncryptionService(this._secureStorage);

  final FlutterSecureStorage _secureStorage;
  final Logger _log = Logger();

  static const String _keyAlias = 'guardian_aes_key';

  Future<enc.Key> _getOrCreateKey() async {
    final stored = await _secureStorage.read(key: _keyAlias);
    if (stored != null) {
      return enc.Key(base64Decode(stored));
    }
    final key = enc.Key.fromSecureRandom(32); // 256-bit
    await _secureStorage.write(key: _keyAlias, value: base64Encode(key.bytes));
    return key;
  }

  Future<String> encrypt(String plaintext) async {
    try {
      final key = await _getOrCreateKey();
      final iv = enc.IV.fromSecureRandom(16);
      final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc));
      final encrypted = encrypter.encrypt(plaintext, iv: iv);
      // Store IV prepended to ciphertext, base64-encoded
      final combined = Uint8List.fromList([...iv.bytes, ...encrypted.bytes]);
      return base64Encode(combined);
    } catch (e) {
      _log.e('Encryption failed', error: e);
      throw const EncryptionException('Failed to encrypt data.');
    }
  }

  Future<String> decrypt(String ciphertext) async {
    try {
      final key = await _getOrCreateKey();
      final combined = base64Decode(ciphertext);
      final iv = enc.IV(Uint8List.fromList(combined.sublist(0, 16)));
      final encrypted = enc.Encrypted(Uint8List.fromList(combined.sublist(16)));
      final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc));
      return encrypter.decrypt(encrypted, iv: iv);
    } catch (e) {
      _log.e('Decryption failed', error: e);
      throw const EncryptionException('Failed to decrypt data.');
    }
  }

  Future<Map<String, dynamic>> encryptFields(
    Map<String, dynamic> data,
    List<String> sensitiveFields,
  ) async {
    final result = Map<String, dynamic>.from(data);
    for (final field in sensitiveFields) {
      if (result.containsKey(field) && result[field] != null) {
        result[field] = await encrypt(result[field].toString());
      }
    }
    return result;
  }

  Future<Map<String, dynamic>> decryptFields(
    Map<String, dynamic> data,
    List<String> sensitiveFields,
  ) async {
    final result = Map<String, dynamic>.from(data);
    for (final field in sensitiveFields) {
      if (result.containsKey(field) && result[field] != null) {
        result[field] = await decrypt(result[field].toString());
      }
    }
    return result;
  }
}
