import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

/// Credentials are supplied at build time; do not hardcode private secrets.
class CloudService {
  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
  static const apiUrl = String.fromEnvironment('BACKEND_URL');
  static bool get configured => supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
  static bool get apiConfigured => apiUrl.isNotEmpty;
  static SupabaseClient get client => Supabase.instance.client;
  static User? get user => configured ? client.auth.currentUser : null;

  static Future<void> initialize() async {
    if (!configured) return;
    await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
  }

  static Future<void> signIn(String email, String password) async {
    if (!configured) throw StateError('Supabase not configured');
    await client.auth.signInWithPassword(email: email, password: password);
  }

  static Future<void> signUp(String email, String password) async {
    if (!configured) throw StateError('Supabase not configured');
    await client.auth.signUp(email: email, password: password);
  }

  static Future<void> signOut() async {
    if (configured) await client.auth.signOut();
  }

  static Future<Map<String, dynamic>?> _request(String method, String path) async {
    final token = client.auth.currentSession?.accessToken;
    if (!configured || !apiConfigured || token == null) return null;
    final uri = Uri.parse(apiUrl).resolve(path);
    final headers = {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'};
    final response = method == 'GET'
        ? await http.get(uri, headers: headers).timeout(const Duration(seconds: 12))
        : await http.put(uri, headers: headers).timeout(const Duration(seconds: 12));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StateError('Sync failed (HTTP ${response.statusCode})');
    }
    return {'data': jsonDecode(response.body)};
  }

  static Future<Set<String>?> loadProgress() async {
    final response = await _request('GET', '/api/v1/progress');
    if (response == null) return null;
    final items = response['data'] as List<dynamic>;
    return items.where((e) => e['completed'] == true).map((e) => e['lesson_id'] as String).toSet();
  }

  static Future<bool> saveProgress(String lessonId) async {
    final response = await _request('PUT', '/api/v1/progress/$lessonId');
    return response != null;
  }
}
