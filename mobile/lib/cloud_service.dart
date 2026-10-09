import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/secure_store.dart';

class ApiException implements Exception {
  const ApiException(this.status);
  final int status;
}

class CloudService {
  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
  static const apiUrl = String.fromEnvironment('BACKEND_URL');
  static const redirectUrl = 'com.piangpi.myanmaracademy://auth-callback';
  static bool _ready = false;
  static bool get configured => _ready;
  static bool get apiConfigured => Uri.tryParse(apiUrl)?.scheme == 'https';
  static SupabaseClient get client => Supabase.instance.client;
  static User? get user => configured ? client.auth.currentUser : null;
  static Stream<AuthState> get authChanges => client.auth.onAuthStateChange;
  static bool initializationFailed = false;

  static Future<void> initialize() async {
    if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) return;
    try {
      final uri = Uri.parse(supabaseUrl);
      if (uri.scheme != 'https' || uri.host.isEmpty) {
        throw const FormatException();
      }
      await Supabase.initialize(
        url: supabaseUrl,
        publishableKey: supabaseAnonKey,
        authOptions: FlutterAuthClientOptions(
          localStorage: SecureSessionStorage(uri.host),
        ),
      );
      _ready = true;
    } catch (_) {
      initializationFailed =
          true; // Guest lessons remain usable; never show raw configuration errors.
    }
  }

  static Future<void> signIn(String email, String password) async {
    await client.auth.signInWithPassword(email: email, password: password);
  }

  static Future<void> signUp(String email, String password) async {
    await client.auth.signUp(
      email: email,
      password: password,
      emailRedirectTo: redirectUrl,
    );
  }

  static Future<void> resetPassword(String email) =>
      client.auth.resetPasswordForEmail(email, redirectTo: redirectUrl);
  static Future<void> updatePassword(String password) async {
    await client.auth.updateUser(UserAttributes(password: password));
  }

  static Future<void> signOut() async {
    if (configured) await client.auth.signOut(scope: SignOutScope.local);
  }

  // Both the request and result belong to expectedUser. Never retry a POST automatically.
  static Future<dynamic> request(
    String method,
    String path, {
    required String expectedUser,
    Map<String, dynamic>? body,
    String? aiKey,
  }) async {
    if (!configured || user?.id != expectedUser) throw const ApiException(401);
    if (!apiConfigured) throw const ApiException(503);
    var session = client.auth.currentSession;
    if (session == null) throw const ApiException(401);
    if (session.isExpired) {
      session = (await client.auth.refreshSession()).session;
    }
    if (session == null || user?.id != expectedUser) {
      throw const ApiException(401);
    }
    final uri = Uri.parse(apiUrl).resolve(path);
    if (uri.scheme != 'https' || uri.userInfo.isNotEmpty) {
      throw const ApiException(503);
    }
    final request = http.Request(method, uri)
      ..followRedirects = false
      ..headers.addAll({
        'Authorization': 'Bearer ${session.accessToken}',
        'Content-Type': 'application/json',
      });
    if (aiKey != null) request.headers['X-AI-Key'] = aiKey;
    if (body != null) request.body = jsonEncode(body);
    final transport = http.Client();
    try {
      final response = await (() async => http.Response.fromStream(
        await transport.send(request),
      ))().timeout(const Duration(seconds: 35));
      if (user?.id != expectedUser) throw const ApiException(401);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ApiException(response.statusCode);
      }
      return jsonDecode(response.body);
    } finally {
      transport.close();
    }
  }

  static Future<Set<String>> loadProgress(String userId) async {
    final items =
        await request('GET', '/api/v1/progress', expectedUser: userId) as List;
    return items
        .where((e) => e['completed'] == true)
        .map((e) => e['lesson_id'] as String)
        .toSet();
  }

  static Future<void> saveProgress(String userId, String lessonId) async {
    await request(
      'PUT',
      '/api/v1/progress/${Uri.encodeComponent(lessonId)}',
      expectedUser: userId,
    );
  }
}
