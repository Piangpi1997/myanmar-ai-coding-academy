import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

const secureStorage = FlutterSecureStorage(
  aOptions: AndroidOptions(encryptedSharedPreferences: true),
);

class SecureSessionStorage extends LocalStorage {
  SecureSessionStorage(this.project);
  final String project;
  String get key => 'session.$project';
  @override
  Future<void> initialize() async {
    // Remove only this project's old plaintext session; keep all learning data.
    final prefs = await SharedPreferences.getInstance();
    final legacyKey = 'sb-${project.split('.').first}-auth-token';
    if (prefs.containsKey(legacyKey) && !await prefs.remove(legacyKey)) {
      throw StateError('Unable to remove legacy session');
    }
  }

  @override
  Future<bool> hasAccessToken() => secureStorage.containsKey(key: key);
  @override
  Future<String?> accessToken() => secureStorage.read(key: key);
  @override
  Future<void> persistSession(String persistSessionString) =>
      secureStorage.write(key: key, value: persistSessionString);
  @override
  Future<void> removePersistedSession() => secureStorage.delete(key: key);
}

class SecurePkceStorage extends GotrueAsyncStorage {
  SecurePkceStorage(this.project);
  final String project;
  String scoped(String key) => 'pkce.$project.$key';
  @override
  Future<String?> getItem({required String key}) =>
      secureStorage.read(key: scoped(key));
  @override
  Future<void> setItem({required String key, required String value}) =>
      secureStorage.write(key: scoped(key), value: value);
  @override
  Future<void> removeItem({required String key}) =>
      secureStorage.delete(key: scoped(key));
}
