import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const secureStorage = FlutterSecureStorage(
  aOptions: AndroidOptions(encryptedSharedPreferences: true),
);

class SecureSessionStorage extends LocalStorage {
  SecureSessionStorage(this.project);
  final String project;
  String get key => 'session.$project';
  @override
  Future<void> initialize() async {}
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
