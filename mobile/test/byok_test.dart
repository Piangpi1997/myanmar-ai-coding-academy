import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
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
}
