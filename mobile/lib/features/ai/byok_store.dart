import 'dart:convert';
import '../../core/secure_store.dart';

const providers = ['openrouter', 'deepseek', 'groq', 'openai'];

class ByokConfig {
  const ByokConfig({
    required this.provider,
    required this.model,
    required this.key,
  });
  final String provider;
  final String model;
  final String key;
  Map<String, String> toJson() => {
    'provider': provider,
    'model': model,
    'key': key,
  };
}

class ByokStore {
  static String _key(String account) => 'byok.v1.$account';
  static Future<ByokConfig?> read(String account) async {
    final value = await secureStorage.read(key: _key(account));
    if (value == null) return null;
    final data = jsonDecode(value) as Map<String, dynamic>;
    if (!providers.contains(data['provider'])) return null;
    return ByokConfig(
      provider: data['provider'] as String,
      model: data['model'] as String,
      key: data['key'] as String,
    );
  }

  static Future<void> save(String account, ByokConfig config) => secureStorage
      .write(key: _key(account), value: jsonEncode(config.toJson()));
  static Future<void> remove(String account) =>
      secureStorage.delete(key: _key(account));
}
