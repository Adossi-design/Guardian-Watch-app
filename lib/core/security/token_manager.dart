import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

// All tokens stored ONLY in flutter_secure_storage (Keychain/Keystore).
// Never persisted to SharedPreferences or Hive plain text.
@lazySingleton
class TokenManager {
  const TokenManager(this._storage);

  final FlutterSecureStorage _storage;

  static const String _fcmTokenKey = 'fcm_device_token';
  static const String _userIdKey = 'user_id';
  static const String _householdIdKey = 'household_id';
  static const String _userRoleKey = 'user_role';
  static const String _lastActiveKey = 'last_active_ts';

  Future<void> saveUserId(String uid) => _storage.write(key: _userIdKey, value: uid);
  Future<String?> getUserId() => _storage.read(key: _userIdKey);

  Future<void> saveHouseholdId(String id) => _storage.write(key: _householdIdKey, value: id);
  Future<String?> getHouseholdId() => _storage.read(key: _householdIdKey);

  Future<void> saveUserRole(String role) => _storage.write(key: _userRoleKey, value: role);
  Future<String?> getUserRole() => _storage.read(key: _userRoleKey);

  Future<void> saveFcmToken(String token) => _storage.write(key: _fcmTokenKey, value: token);
  Future<String?> getFcmToken() => _storage.read(key: _fcmTokenKey);

  Future<void> updateLastActive() => _storage.write(
        key: _lastActiveKey,
        value: DateTime.now().millisecondsSinceEpoch.toString(),
      );

  Future<DateTime?> getLastActive() async {
    final ts = await _storage.read(key: _lastActiveKey);
    if (ts == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(int.parse(ts));
  }

  Future<bool> isSessionExpired() async {
    final last = await getLastActive();
    if (last == null) return true;
    // Auto logout after 30 days of inactivity
    return DateTime.now().difference(last).inDays >= 30;
  }

  Future<void> clearAll() => _storage.deleteAll();
}
