"""No live execution or database: substitutes verify grading boundaries."""
import hashlib
from unittest.mock import AsyncMock
from uuid import uuid4
import pytest
from fastapi import HTTPException
from fastapi.testclient import TestClient
from app import assessments, auth
from app.config import settings
from app.limits import limiter
from app.main import app
from app.runner import RunOutput
USER = '12345678-1234-1234-1234-123456789012'
OTHER = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'

@pytest.fixture
def client(monkeypatch):
    app.dependency_overrides[auth.current_user] = lambda: (USER, 'user-token')
    limiter.windows.clear()
    monkeypatch.setattr(settings, 'supabase_url', 'https://test.supabase.co')
    monkeypatch.setattr(settings, 'supabase_secret_key', 'sb_secret_fake-test-only')
    monkeypatch.setattr(settings, 'judge0_sandbox_verified', True)
    with TestClient(app) as c:
        yield c
    app.dependency_overrides.clear()

def persistence(monkeypatch):
    records, queries = {}, []
    async def store(method, query, body=None):
        queries.append((method, query, body))
        if method == 'GET':
            if 'id=eq.' in query:
                sid = query.split('id=eq.')[1].split('&')[0]
                row = records.get(sid)
                return [row.copy()] if row and row['user_id'] == USER else []
            return [row.copy() for row in records.values() if row['user_id'] == USER]
        if method == 'POST':
            records[body['id']] = body.copy()
            return [body.copy()]
        sid = query.split('id=eq.')[1].split('&')[0]
        records[sid].update(body)
        return [records[sid].copy()]
    monkeypatch.setattr(assessments, 'storage', store)
    return records, queries

def payload():
    return {'submission_id': str(uuid4()), 'code': 'print("learner code")'}

def result(output, **kwargs):
    return RunOutput(status_id=kwargs.pop('status_id', 3), status='Test substitute', stdout=output,
                     stderr='', compile_output='', **kwargs)

def test_grade_requires_authentication():
    with TestClient(app) as client:
        assert client.post('/api/v1/practice/sum-two/submit', json=payload()).status_code == 401

def test_missing_storage_or_runner_fails_closed(client, monkeypatch):
    monkeypatch.setattr(settings, 'supabase_secret_key', '')
    assert client.post('/api/v1/practice/sum-two/submit', json=payload()).status_code == 503
    monkeypatch.setattr(settings, 'supabase_secret_key', 'server-test-key')
    monkeypatch.setattr(settings, 'judge0_sandbox_verified', False)
    assert client.post('/api/v1/practice/sum-two/submit', json=payload()).status_code == 503

def test_actual_outputs_compared_and_repeat_does_not_execute(client, monkeypatch):
    records, queries = persistence(monkeypatch)
    async def run(value, owner):
        assert owner[0] == USER
        return result(str(sum(map(int, value.stdin.split()))) + '\n')
    execute = AsyncMock(side_effect=run)
    monkeypatch.setattr(assessments, 'run', execute)
    request = payload()
    response = client.post('/api/v1/practice/sum-two/submit', json=request)
    assert response.status_code == 200
    data = response.json()
    assert data['feedback'] == 'passed' and data['passed_count'] == data['total_count'] == 3
    assert not {'stdin','stdout','expected','code','code_hash','user_id'} & data.keys()
    assert records[request['submission_id']]['user_id'] == USER
    assert records[request['submission_id']]['code_hash'] == hashlib.sha256(request['code'].encode()).hexdigest()
    assert all(f'user_id=eq.{USER}' in query for method, query, _ in queries if method in ('GET','PATCH'))
    assert client.post('/api/v1/practice/sum-two/submit', json=request).json() == data
    assert execute.await_count == 3
    request['code'] = 'changed code'
    assert client.post('/api/v1/practice/sum-two/submit', json=request).status_code == 409
    assert execute.await_count == 3

@pytest.mark.parametrize('output,extra,feedback', [('wrong', {}, 'wrong_answer'), ('', {'status_id': 6}, 'runtime_error'),
    ('', {'status_id': 5}, 'timeout'), ('partial', {'truncated': True}, 'output_limit')])
def test_failures_never_return_success_or_private_oracles(client, monkeypatch, output, extra, feedback):
    persistence(monkeypatch)
    monkeypatch.setattr(assessments, 'run', AsyncMock(return_value=result(output, **extra)))
    response = client.post('/api/v1/practice/even-number/submit', json=payload())
    assert response.status_code == 200
    assert response.json()['feedback'] == feedback and response.json()['passed_count'] == 0
    assert not {'stdin','expected','stdout','stderr'} & response.json().keys()

def test_execution_failure_is_saved_without_provider_details(client, monkeypatch):
    records, _ = persistence(monkeypatch)
    monkeypatch.setattr(assessments, 'run', AsyncMock(side_effect=HTTPException(502, 'sensitive upstream body')))
    request = payload()
    response = client.post('/api/v1/practice/safe-age/submit', json=request)
    assert response.json()['state'] == 'error' and response.json()['feedback'] == 'service_unavailable'
    assert 'sensitive' not in response.text and records[request['submission_id']]['state'] == 'error'

def test_unknown_id_and_client_identity_rejected(client, monkeypatch):
    persistence(monkeypatch)
    assert client.post('/api/v1/practice/unknown/submit', json=payload()).status_code == 404
    assert client.post('/api/v1/practice/sum-two/submit', json={**payload(), 'user_id': OTHER}).status_code == 422

def test_pending_repeat_and_foreign_owner_do_not_execute(client, monkeypatch):
    records, _ = persistence(monkeypatch)
    request = payload()
    records[request['submission_id']] = {'id': request['submission_id'], 'user_id': USER, 'exercise_id': 'sum-two',
        'code_hash': hashlib.sha256(request['code'].encode()).hexdigest(), 'state': 'pending', 'feedback': 'pending',
        'passed_count': 0, 'total_count': 3}
    execute = AsyncMock()
    monkeypatch.setattr(assessments, 'run', execute)
    assert client.post('/api/v1/practice/sum-two/submit', json=request).json()['state'] == 'pending'
    assert execute.await_count == 0
    records[request['submission_id']]['user_id'] = OTHER
    assert client.get('/api/v1/practice/attempts/' + request['submission_id']).status_code == 404

def test_server_headers_never_use_user_jwt(client, monkeypatch):
    request = AsyncMock(return_value=[])
    monkeypatch.setattr(assessments, 'request_json', request)
    assert client.get('/api/v1/practice/attempts').status_code == 200
    headers = request.call_args.kwargs['headers']
    assert headers['apikey'] == 'sb_secret_fake-test-only' and 'Authorization' not in headers
    monkeypatch.setattr(settings, 'supabase_secret_key', 'legacy-service-role-test')
    client.get('/api/v1/practice/attempts')
    assert request.call_args.kwargs['headers']['Authorization'] == 'Bearer legacy-service-role-test'

@pytest.mark.parametrize('exercise', sorted(assessments.EXERCISE_IDS))
def test_oracles_respect_public_problem_boundaries(exercise):
    cases = assessments.test_cases(exercise)
    assert len(cases) == 3 and all(len(i) <= 4000 and len(o) <= 4000 for i,o in cases)
    for stdin, expected in cases:
        if exercise == 'sum-two': assert int(expected) == sum(map(int, stdin.split()))
        if exercise == 'discount-price':
            price, discount = map(int, stdin.split())
            assert 0 <= price <= 10000 and 0 <= discount <= 100
            assert int(expected) == price * (100 - discount) // 100
        if exercise == 'sum-list':
            lines = stdin.splitlines()
            numbers = list(map(int, lines[1].split())) if len(lines) > 1 else []
            assert len(numbers) == int(lines[0]) and int(expected) == sum(numbers)

def test_history_readable_when_runner_is_disabled(client, monkeypatch):
    monkeypatch.setattr(settings, 'judge0_sandbox_verified', False)
    monkeypatch.setattr(assessments, 'storage', AsyncMock(return_value=[]))
    assert client.get('/api/v1/practice/attempts').status_code == 200

def test_grade_quota_applies_only_to_new_execution(client, monkeypatch):
    persistence(monkeypatch)
    monkeypatch.setattr(assessments, 'run', AsyncMock(return_value=result('wrong')))
    for _ in range(3):
        assert client.post('/api/v1/practice/even-number/submit', json=payload()).status_code == 200
    assert client.post('/api/v1/practice/even-number/submit', json=payload()).status_code == 429

def test_internal_runner_error_does_not_blame_student_code(client, monkeypatch):
    persistence(monkeypatch)
    monkeypatch.setattr(assessments, 'run', AsyncMock(return_value=result('', status_id=13)))
    data = client.post('/api/v1/practice/sum-two/submit', json=payload()).json()
    assert data['state'] == 'error' and data['feedback'] == 'service_unavailable'

@pytest.mark.parametrize('output', ['3\n\n', '3 \n', 'debug\n3\n'])
def test_padding_and_extra_output_are_not_accepted(client, monkeypatch, output):
    persistence(monkeypatch)
    monkeypatch.setattr(assessments, 'test_cases', lambda _: [('1\n2\n', '3')])
    monkeypatch.setattr(assessments, 'run', AsyncMock(return_value=result(output)))
    data = client.post('/api/v1/practice/sum-two/submit', json=payload()).json()
    assert data['feedback'] == 'wrong_answer' and data['passed_count'] == 0
