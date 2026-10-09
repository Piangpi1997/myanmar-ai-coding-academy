import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:myanmar_ai_coding_academy/core/secure_store.dart';
import 'package:myanmar_ai_coding_academy/features/ai/byok_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => FlutterSecureStorage.setMockInitialValues({}));
  test(
    'BYOK credentials are account-scoped and removable without touching other accounts',
    () async {
      await ByokStore.save(
        'A',
        const ByokConfig(
          provider: 'openrouter',
          model: 'vendor/model',
          key: 'fake-test-key-a',
        ),
      );
      await ByokStore.save(
        'B',
        const ByokConfig(
          provider: 'groq',
          model: 'vendor/model',
          key: 'fake-test-key-b',
        ),
      );
      expect((await ByokStore.read('A'))!.provider, 'openrouter');
      expect((await ByokStore.read('B'))!.key, 'fake-test-key-b');
      await ByokStore.remove('A');
      expect(await ByokStore.read('A'), isNull);
      expect((await ByokStore.read('B'))!.provider, 'groq');
    },
  );
  test(
    'Session upgrade removes only this project plaintext token and preserves progress',
    () async {
      SharedPreferences.setMockInitialValues({
        'sb-project-auth-token': 'fake-old-session',
        'sb-other-auth-token': 'fake-other-session',
        'completed_lessons': ['py-01'],
      });
      await SecureSessionStorage('project.supabase.co').initialize();
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.containsKey('sb-project-auth-token'), isFalse);
      expect(prefs.getString('sb-other-auth-token'), 'fake-other-session');
      expect(prefs.getStringList('completed_lessons'), ['py-01']);
    },
  );
  test('PKCE verifier storage stays project-scoped', () async {
    final first = SecurePkceStorage('first.supabase.co');
    final second = SecurePkceStorage('second.supabase.co');
    await first.setItem(key: 'verifier', value: 'fake-verifier');
    expect(await first.getItem(key: 'verifier'), 'fake-verifier');
    expect(await second.getItem(key: 'verifier'), isNull);
    await first.removeItem(key: 'verifier');
    expect(await first.getItem(key: 'verifier'), isNull);
  });
}
