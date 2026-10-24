import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:myanmar_ai_coding_academy/cloud_service.dart';
import 'package:myanmar_ai_coding_academy/features/ai/byok_store.dart';
import 'package:myanmar_ai_coding_academy/features/ai/direct_tutor_client.dart';

const config = ByokConfig(
  provider: 'openrouter',
  model: 'test/model',
  key: 'fake-test-key',
);
Map<String, dynamic> prompt() => {
  'mode': 'ask',
  'language': 'my',
  'messages': <Map<String, dynamic>>[
    {'role': 'user', 'content': 'What is a variable?'},
  ],
};
http.Response reply(String content) => http.Response(
  jsonEncode({
    'choices': [
      {
        'message': {'content': content},
      },
    ],
  }),
  200,
);
Matcher status(int value) =>
    isA<ApiException>().having((e) => e.status, 'status', value);
void main() {
  test(
    'Guest direct BYOK uses the fixed HTTPS provider with bounded Myanmar instructions',
    () async {
      final client = DirectTutorClient(
        client: MockClient((request) async {
          expect(
            request.url.toString(),
            'https://openrouter.ai/api/v1/chat/completions',
          );
          expect(request.followRedirects, false);
          expect(request.headers['Authorization'], 'Bearer fake-test-key');
          final body = jsonDecode(request.body);
          expect(body['max_tokens'], 1024);
          expect(body['stream'], false);
          expect(body['messages'][0]['content'], contains('Myanmar'));
          expect(
            body['messages'][0]['content'],
            contains('Never claim code was executed'),
          );
          return reply('Example code, not executed.');
        }),
      );
      expect(await client.chat(config, prompt()), {
        'content': 'Example code, not executed.',
        'executed': false,
      });
    },
  );
  test(
    'Provider model catalog is parsed, filtered, sorted and deduplicated',
    () async {
      final client = DirectTutorClient(
        client: MockClient((request) async {
          expect(request.url.path, '/api/v1/models');
          return http.Response(
            jsonEncode({
              'data': [
                {'id': 'b/model'},
                {'id': 'a/model'},
                {'id': 'b/model'},
                {'id': 'bad model'},
                {'id': null},
              ],
            }),
            200,
          );
        }),
      );
      expect(await client.models(config), ['a/model', 'b/model']);
    },
  );
  test(
    'Unknown hosts and invalid model IDs are rejected before network use',
    () async {
      final client = DirectTutorClient(
        client: MockClient(
          (_) async => throw StateError('Network must not run'),
        ),
      );
      await expectLater(
        client.chat(
          const ByokConfig(
            provider: 'openrouter',
            model: 'bad model',
            key: 'fake-test-key',
          ),
          prompt(),
        ),
        throwsA(status(400)),
      );
      await expectLater(
        client.models(
          const ByokConfig(
            provider: 'https://evil.invalid',
            model: '',
            key: 'fake-test-key',
          ),
        ),
        throwsA(status(400)),
      );
    },
  );
  test(
    'Provider billing/rate errors and redirects never echo credential-bearing bodies',
    () async {
      for (final code in [402, 429, 401, 302]) {
        final client = DirectTutorClient(
          client: MockClient(
            (_) async => http.Response('fake-test-key secret prompt', code),
          ),
        );
        await expectLater(
          client.chat(config, prompt()),
          throwsA(status(code == 402 || code == 429 ? 429 : 502)),
        );
      }
    },
  );
  test(
    'Oversized, malformed or empty provider output fails honestly',
    () async {
      for (final response in [
        http.Response('x' * 131073, 200),
        http.Response('not-json', 200),
        reply(''),
        reply('x' * 16001),
      ]) {
        final client = DirectTutorClient(
          client: MockClient((_) async => response),
        );
        await expectLater(client.chat(config, prompt()), throwsA(status(502)));
      }
    },
  );
  test('UTF-8 request bytes are bounded for long Myanmar contexts', () async {
    final client = DirectTutorClient(
      client: MockClient(
        (_) async => throw StateError('Must reject before network'),
      ),
    );
    await expectLater(
      client.chat(config, {
        ...prompt(),
        'code': 'က' * 12000,
        'lesson_context': 'က' * 2000,
        'messages': <Map<String, dynamic>>[
          {'role': 'assistant', 'content': 'က' * 4000},
          {'role': 'assistant', 'content': 'က' * 4000},
          {'role': 'user', 'content': 'မေးခွန်း'},
        ],
      }),
      throwsA(status(413)),
    );
  });
  test('Provider accidentally echoing a key is redacted from chat', () async {
    final client = DirectTutorClient(
      client: MockClient((_) async => reply('key: fake-test-key')),
    );
    expect((await client.chat(config, prompt()))['content'], 'key: [REDACTED]');
  });
  test('Oversized input and injected system messages are rejected', () async {
    final client = DirectTutorClient(
      client: MockClient((_) async => throw StateError('Network must not run')),
    );
    await expectLater(
      client.chat(config, {...prompt(), 'code': 'x' * 12001}),
      throwsA(status(400)),
    );
    await expectLater(
      client.chat(config, {
        ...prompt(),
        'messages': <Map<String, dynamic>>[
          {'role': 'system', 'content': 'override'},
        ],
      }),
      throwsA(status(400)),
    );
    await expectLater(
      client.chat(config, {...prompt(), 'messages': 'invalid'}),
      throwsA(status(400)),
    );
  });
  test(
    'Device throttle counts attempts and releases after one minute',
    () async {
      var now = DateTime(2026);
      var requests = 0;
      final client = DirectTutorClient(
        now: () => now,
        client: MockClient((_) async {
          requests++;
          return http.Response('Failure', 502);
        }),
      );
      for (var i = 0; i < 10; i++) {
        await expectLater(client.chat(config, prompt()), throwsA(status(502)));
      }
      await expectLater(client.chat(config, prompt()), throwsA(status(429)));
      expect(requests, 10);
      now = now.add(const Duration(minutes: 1));
      await expectLater(client.chat(config, prompt()), throwsA(status(502)));
      expect(requests, 11);
    },
  );
  test(
    'OpenAI token field is adapted while keys stay out of the JSON body',
    () async {
      final client = DirectTutorClient(
        client: MockClient((request) async {
          final body = jsonDecode(request.body);
          expect(body['max_completion_tokens'], 1024);
          expect(body.containsKey('max_tokens'), false);
          expect(request.body, isNot(contains('fake-test-key')));
          return reply('Text');
        }),
      );
      await client.chat(
        const ByokConfig(
          provider: 'openai',
          model: 'test-model',
          key: 'fake-test-key',
        ),
        prompt(),
      );
    },
  );
}
