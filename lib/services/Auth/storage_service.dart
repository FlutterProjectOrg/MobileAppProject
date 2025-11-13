// storage_service.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // --- Generics ---
  Future<void> write(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  Future<String?> read(String key) async {
    return await _storage.read(key: key);
  }

  Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }

  // --- user id helpers (existants, conservés) ---
  Future<void> saveUserId(int userId) async {
    await write('user_id', userId.toString());
  }

  Future<int?> getUserId() async {
    final value = await read('user_id');
    if (value == null) return null;
    return int.tryParse(value);
  }

  Future<void> clearSession() async {
    await delete('user_id');
  }

  // --- biometric helpers (convenience) ---
  Future<void> saveBiometricEnabled(bool enabled) async {
    await write('biometric_enabled', enabled ? 'true' : 'false');
  }

  Future<bool> isBiometricEnabled() async {
    final v = await read('biometric_enabled');
    return v == 'true';
  }

  Future<void> saveBiometricUserId(int userId) async {
    await write('biometric_user_id', userId.toString());
  }

  Future<int?> getBiometricUserId() async {
    final v = await read('biometric_user_id');
    if (v == null) return null;
    return int.tryParse(v);
  }

  Future<void> clearBiometric() async {
    await delete('biometric_enabled');
    await delete('biometric_user_id');
  }
}
