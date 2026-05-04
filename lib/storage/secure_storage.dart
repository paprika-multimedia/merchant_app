import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Wrapper around [FlutterSecureStorage] with typed key constants.
///
/// All sensitive data (tokens, locale, recent amounts) must go through here.
/// Never use [SharedPreferences] for secrets.
class SecureStorage {
  SecureStorage() : _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  final FlutterSecureStorage _storage;

  // ─── Key constants ──────────────────────────────────────────────────────────
  static const keySessionToken = 'session_token';
  static const keyRefreshToken = 'refresh_token';
  static const keyDeviceId = 'device_id';
  static const keyLang = 'paprika-lang';

  static String recentAmountsKey(String merchantId, String flow) =>
      'paprika-recent-amounts:$merchantId:$flow';

  // ─── Typed helpers ──────────────────────────────────────────────────────────

  /// Reads a string value. Returns null if not set.
  Future<String?> read(String key) => _storage.read(key: key);

  /// Writes a string value.
  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);

  /// Deletes a key.
  Future<void> delete(String key) => _storage.delete(key: key);

  /// Deletes all stored values. Used on logout.
  Future<void> deleteAll() => _storage.deleteAll();
}
