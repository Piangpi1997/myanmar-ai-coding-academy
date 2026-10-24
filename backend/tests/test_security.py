"""All upstream responses here are mocked; these tests do not call paid services."""
import asyncio
import base64
import time
from types import SimpleNamespace
from unittest.mock import AsyncMock

import httpx
import jwt
import pytest
from cryptography.hazmat.primitives.asymmetric import rsa
from fastapi.testclient import TestClient

from app import ai, auth, main, runner, upstream
from app.config import settings
from app.limits import limiter
from app.main import app

USER = '12345678-1234-1234-1234-123456789012'
OTHER = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'
KEY = 'test-byok-credential'
CHAT = {'provider': 'openrouter', 'model': 'vendor/model', 'messages': [{'role': 'user', 'content': 'Explain variables'}]}


@pytest.fixture
def client():
    app.dependency_overrides[auth.current_user] = lambda: (USER, 'user-session')
    limiter.windows.clear()
    with TestClient(app) as c:
        yield c
    app.dependency_overrides.clear()


def test_progress_uses_authenticated_identity(client, monkeypatch):
    storage = AsyncMock(return_value=[{'lesson_id': 'py-01', 'completed': True}])
    monkeypatch.setattr(main, 'supabase_request', storage)
    response = client.put('/api/v1/progress/py-01', json={'user_id': OTHER})
    assert response.status_code == 200
    assert storage.call_args.args[3]['user_id'] == USER
    client.get('/api/v1/progress')
    assert f'user_id=eq.{USER}' in storage.call_args.args[1]


def test_invalid_id_is_422_after_authentication(client):
    assert client.put('/api/v1/progress/INVALID%20LESSON').status_code == 422


def test_ai_requires_key(client):
    assert client.post('/api/v1/ai/chat', json=CHAT).status_code == 400


@pytest.mark.parametrize('provider', list(ai.PROVIDERS))
def test_provider_routing_and_credentials(client, monkeypatch, provider):
    request = AsyncMock(return_value={'choices': [{'message': {'content': 'A variable stores a value.'}}]})
    monkeypatch.setattr(ai, 'request_json', request)
    response = client.post('/api/v1/ai/chat', json={**CHAT, 'provider': provider}, headers={'X-AI-Key': KEY})
    assert response.status_code == 200
    assert response.json()['executed'] is False
    args, kwargs = request.call_args
    assert args == ('POST', ai.PROVIDERS[provider])
    assert kwargs['headers'] == {'Authorization': 'Bearer ' + KEY}
    assert KEY not in str(kwargs['body'])
    assert 'Myanmar' in kwargs['body']['messages'][0]['content']
    assert 'has no execution tool' in kwargs['body']['messages'][0]['content']
    assert KEY not in response.text


@pytest.mark.parametrize('change', [
    {'provider': 'http://169.254.169.254'},
    {'base_url': 'https://attacker.example'},
    {'messages': [{'role': 'system', 'content': KEY}]},
    {'max_tokens': 100000},
    {'model': '../../ bad'},
    {'messages': [{'role': 'assistant', 'content': KEY}]},
    {'messages': [{'role': 'user', 'content': 'x' * 4001}]},
])
def test_reject_invalid_ai_input_without_echo(client, change):
    response = client.post('/api/v1/ai/chat', json={**CHAT, **change}, headers={'X-AI-Key': KEY})
    assert response.status_code == 422
    assert KEY not in response.text


def test_key_echo_redacted(client, monkeypatch):
    monkeypatch.setattr(ai, 'request_json', AsyncMock(return_value={'choices': [{'message': {'content': KEY}}]}))
    response = client.post('/api/v1/ai/chat', json=CHAT, headers={'X-AI-Key': KEY})
    assert KEY not in response.text
    assert '[REDACTED]' in response.text


def test_rate_limit_per_account(client, monkeypatch):
    request = AsyncMock(return_value={'choices': [{'message': {'content': 'Answer'}}]})
    monkeypatch.setattr(ai, 'request_json', request)
    for _ in range(10):
        assert client.post('/api/v1/ai/chat', json=CHAT, headers={'X-AI-Key': KEY}).status_code == 200
    assert client.post('/api/v1/ai/chat', json=CHAT, headers={'X-AI-Key': KEY}).status_code == 429
    app.dependency_overrides[auth.current_user] = lambda: (OTHER, 'another-session')
    assert client.post('/api/v1/ai/chat', json=CHAT, headers={'X-AI-Key': KEY}).status_code == 200
    assert request.await_count == 11


def test_body_limit(client):
    response = client.post('/api/v1/ai/chat', content=b'x' * 65537, headers={'Content-Type': 'application/json'})
    assert response.status_code == 413


def test_runner_fails_closed(client, monkeypatch):
    monkeypatch.setattr(settings, 'judge0_sandbox_verified', False)
    assert client.post('/api/v1/code/run', json={'code': 'print(1)'}).status_code == 503


def test_runner_payload_and_actual_decoded_output(client, monkeypatch):
    monkeypatch.setattr(settings, 'judge0_sandbox_verified', True)
    monkeypatch.setattr(settings, 'judge0_url', 'https://runner.example')
    request = AsyncMock(side_effect=[{'token': OTHER}, {'status': {'id': 3, 'description': 'Accepted'},
        'stdout': base64.b64encode('မင်္ဂလာပါ\n'.encode()).decode(), 'stderr': None}])
    monkeypatch.setattr(runner, 'request_json', request)
    monkeypatch.setattr(runner.asyncio, 'sleep', AsyncMock())
    response = client.post('/api/v1/code/run', json={'code': 'print("မင်္ဂလာပါ")', 'stdin': 'test'})
    assert response.status_code == 200
    assert response.json()['stdout'] == 'မင်္ဂလာပါ\n'
    body = request.call_args_list[0].kwargs['body']
    assert body['enable_network'] is False
    assert body['cpu_time_limit'] == 2 and body['memory_limit'] == 65536
    assert base64.b64decode(body['source_code']).decode() == 'print("မင်္ဂလာပါ")'
    assert base64.b64decode(body['stdin']).decode() == 'test'


def test_runner_invalid_job_token_never_follows_url(client, monkeypatch):
    monkeypatch.setattr(settings, 'judge0_sandbox_verified', True)
    monkeypatch.setattr(settings, 'judge0_url', 'https://runner.example')
    request = AsyncMock(return_value={'token': '../../private'})
    monkeypatch.setattr(runner, 'request_json', request)
    assert client.post('/api/v1/code/run', json={'code': 'print(1)'}).status_code == 502
    assert request.await_count == 1


@pytest.mark.parametrize('status, expected', [(401, 502), (402, 429), (429, 429), (500, 502), (302, 502)])
def test_upstream_errors_do_not_leak_credentials(monkeypatch, status, expected):
    real_client = httpx.AsyncClient
    def handler(request):
        return httpx.Response(status, json={'error': KEY}, headers={'Location': 'https://attacker.example'})
    monkeypatch.setattr(upstream.httpx, 'AsyncClient', lambda **kwargs: real_client(transport=httpx.MockTransport(handler), **kwargs))
    from fastapi import HTTPException
    with pytest.raises(HTTPException) as e:
        asyncio.run(upstream.request_json('POST', 'https://provider.example', headers={'Authorization': KEY}))
    assert e.value.status_code == expected
    assert KEY not in str(e.value.detail)


def test_upstream_response_limit(monkeypatch):
    real_client = httpx.AsyncClient
    monkeypatch.setattr(upstream.httpx, 'AsyncClient', lambda **kwargs: real_client(
        transport=httpx.MockTransport(lambda req: httpx.Response(200, content=b'x' * 1025)), **kwargs))
    from fastapi import HTTPException
    with pytest.raises(HTTPException) as e:
        asyncio.run(upstream.request_json('GET', 'https://provider.example', max_bytes=1024))
    assert e.value.status_code == 502


@pytest.fixture
def signed_token(monkeypatch):
    private = rsa.generate_private_key(public_exponent=65537, key_size=2048)
    monkeypatch.setattr(settings, 'supabase_url', 'https://test.supabase.co')
    monkeypatch.setattr(settings, 'supabase_anon_key', 'public-test-key')
    monkeypatch.setattr(auth, 'jwks_client', lambda _: SimpleNamespace(get_signing_key_from_jwt=lambda token: SimpleNamespace(key=private.public_key())))
    def create(**override):
        claims = {'sub': USER, 'role': 'authenticated', 'iss': 'https://test.supabase.co/auth/v1',
                  'aud': 'authenticated', 'iat': int(time.time()) - 1, 'exp': int(time.time()) + 600}
        claims.update(override)
        return jwt.encode(claims, private, algorithm='RS256')
    return create


def test_signed_jwt_accepted(signed_token):
    assert auth.verify_token(signed_token()) == USER


@pytest.mark.parametrize('override', [{'exp': 1}, {'aud': 'wrong'}, {'iss': 'https://attacker.example'},
                                     {'role': 'service_role'}, {'sub': 'not-a-uuid'}])
def test_invalid_jwt_rejected(signed_token, override):
    with TestClient(app) as client:
        response = client.get('/api/v1/progress', headers={'Authorization': 'Bearer ' + signed_token(**override)})
    assert response.status_code == 401


def test_unsigned_token_rejected():
    with pytest.raises(jwt.InvalidTokenError):
        auth.verify_token(jwt.encode({'sub': USER}, '', algorithm='none'))
