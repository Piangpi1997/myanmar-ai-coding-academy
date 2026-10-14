"""Authenticated stdin/stdout grading; private expected outputs never leave the server.

Every execution uses the existing verified Judge0 adapter. No eval/exec/subprocess
runs learner code in this API process. Records contain a digest, not source/stdin.
"""
import asyncio
import hashlib
import secrets
import string
from datetime import datetime, timezone
from typing import Annotated, Literal
from urllib.parse import urlparse
from uuid import UUID

from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel, ConfigDict, Field

from .auth import current_user
from .config import settings
from .limits import limiter
from .runner import RunInput, run
from .upstream import request_json

router = APIRouter(prefix='/api/v1/practice', tags=['Private assessments'])
# Generate fresh conformance inputs only on a new submission. The mobile catalog
# contains public worked examples, not these per-attempt input/output oracles.
EXERCISE_IDS = {'sum-two', 'even-number', 'discount-price', 'count-vowels', 'sum-list', 'safe-age'}
_rng = secrets.SystemRandom()


def test_cases(exercise_id):
    if exercise_id == 'sum-two':
        pairs = [(0, 0)] + [(_rng.randint(-100000, 100000), _rng.randint(-100000, 100000)) for _ in range(2)]
        return [(f'{a}\n{b}\n', str(a + b)) for a, b in pairs]
    if exercise_id == 'even-number':
        values = [0, -2 * _rng.randint(1, 1000) - 1, 2 * _rng.randint(1, 1000)]
        return [(f'{n}\n', 'even' if n % 2 == 0 else 'odd') for n in values]
    if exercise_id == 'discount-price':
        pairs = [(0, 5), (_rng.randint(1, 10000), 100), (_rng.randint(101, 10000), _rng.randint(1, 99))]
        return [(f'{price}\n{percent}\n', str(price * (100 - percent) // 100)) for price, percent in pairs]
    if exercise_id == 'count-vowels':
        values = ['', 'AEIOU' + ''.join(_rng.choices(string.ascii_letters, k=30)), ''.join(_rng.choices(string.ascii_letters, k=40))]
        return [(value + '\n', str(sum(c.lower() in 'aeiou' for c in value))) for value in values]
    if exercise_id == 'sum-list':
        values = [[], [_rng.randint(-1000, 1000) for _ in range(4)], [-_rng.randint(1, 1000) for _ in range(3)]]
        return [(f"{len(numbers)}\n{' '.join(map(str, numbers))}\n", str(sum(numbers))) for numbers in values]
    # Valid bounds are inclusive, and invalid text and negative age are rejected.
    values = ['not-an-age', str(-_rng.randint(1, 1000)), str(_rng.randint(0, 120))]
    return [(value + '\n', str(int(value) + 1) if value.isdigit() else 'invalid') for value in values]



class SubmissionInput(BaseModel):
    model_config = ConfigDict(extra='forbid')
    submission_id: UUID
    code: str = Field(min_length=1, max_length=16000)


class GradeRecord(BaseModel):
    id: UUID
    exercise_id: str
    state: Literal['pending', 'complete', 'error']
    passed_count: int = Field(ge=0, le=3)
    total_count: int = Field(ge=1, le=3)
    feedback: Literal['pending', 'passed', 'wrong_answer', 'runtime_error', 'timeout', 'output_limit', 'service_unavailable']
    created_at: datetime | None = None


def configured(*, require_runner=True):
    parsed = urlparse(settings.supabase_url)
    if (not settings.supabase_secret_key or parsed.scheme != 'https' or not parsed.hostname
            or parsed.username or parsed.query or parsed.fragment):
        raise HTTPException(503, 'Assessment storage is not configured')
    if require_runner and not settings.judge0_sandbox_verified:
        raise HTTPException(503, 'Verified sandbox is not configured')


async def storage(method, query, body=None):
    # New sb_secret keys identify the server role through apikey; they are not JWTs.
    key = settings.supabase_secret_key
    headers = {'apikey': key, 'Content-Type': 'application/json', 'Prefer': 'return=representation'}
    if not key.startswith('sb_secret_'):
        headers['Authorization'] = 'Bearer ' + key  # Legacy service_role JWT support.
    return await request_json(method, settings.supabase_url.rstrip('/') + '/rest/v1/code_submissions' + query,
                              headers=headers, body=body, timeout=8)


def response_record(row):
    try:
        return GradeRecord.model_validate(row)
    except (ValueError, TypeError):
        raise HTTPException(502, 'Invalid assessment record') from None


@router.get('/attempts', response_model=list[GradeRecord])
async def attempts(auth: Annotated[tuple[str, str], Depends(current_user)]):
    configured(require_runner=False)
    limiter.check(auth[0], 'assessment-read', minute=60, day=2000)
    rows = await storage('GET', f'?user_id=eq.{auth[0]}&order=created_at.desc&limit=30')
    if not isinstance(rows, list):
        raise HTTPException(502, 'Invalid assessment history')
    return [response_record(row) for row in rows]


@router.get('/attempts/{submission_id}', response_model=GradeRecord)
async def attempt(submission_id: UUID, auth: Annotated[tuple[str, str], Depends(current_user)]):
    configured(require_runner=False)
    limiter.check(auth[0], 'assessment-read', minute=60, day=2000)
    rows = await storage('GET', f'?id=eq.{submission_id}&user_id=eq.{auth[0]}&limit=1')
    if not isinstance(rows, list) or not rows:
        raise HTTPException(404, 'Attempt not found')
    return response_record(rows[0])


@router.post('/{exercise_id}/submit', response_model=GradeRecord)
async def submit(exercise_id: str, payload: SubmissionInput,
                 auth: Annotated[tuple[str, str], Depends(current_user)]):
    if exercise_id not in EXERCISE_IDS:
        raise HTTPException(404, 'Exercise not found')
    configured()
    limiter.check(auth[0], 'assessment-request', minute=30, day=1000)
    digest = hashlib.sha256(payload.code.encode()).hexdigest()
    sid = str(payload.submission_id)
    query = f'?id=eq.{sid}&user_id=eq.{auth[0]}'
    existing = await storage('GET', query + '&limit=1')
    if not isinstance(existing, list):
        raise HTTPException(502, 'Invalid assessment history')
    if existing:
        row = existing[0]
        if row.get('exercise_id') != exercise_id or row.get('code_hash') != digest:
            raise HTTPException(409, 'Submission ID already used for different code')
        # Reconnects never submit paid execution again. A pending record represents
        # interrupted/ongoing work; users explicitly start a new attempt if needed.
        return response_record(row)
    limiter.check(auth[0], 'grade', minute=3, day=50)
    cases = test_cases(exercise_id)
    total = len(cases)
    row = {'id': sid, 'user_id': auth[0], 'exercise_id': exercise_id, 'code_hash': digest,
           'state': 'pending', 'passed_count': 0, 'total_count': total, 'feedback': 'pending'}
    # Plain INSERT (not upsert): a racing duplicate cannot overwrite a completed
    # result or start executions. The unique id makes that request fail safely.
    created = await storage('POST', '', row)
    if not isinstance(created, list) or len(created) != 1:
        raise HTTPException(502, 'Attempt could not be recorded')
    passed = 0
    feedback = 'wrong_answer'
    state = 'complete'
    try:
        async with asyncio.timeout(28):
            for stdin, expected in cases:
                result = await run(RunInput(code=payload.code, stdin=stdin), auth)
                if result.truncated:
                    feedback = 'output_limit'
                    break
                if result.status_id in (13, 14):
                    state, feedback = 'error', 'service_unavailable'
                    break
                if result.status_id != 3:
                    feedback = 'timeout' if result.status_id == 5 else 'runtime_error'
                    break
                # Normalize line endings and the final newline only. Spaces and
                # extra prints remain significant; they are not valid answers.
                actual = result.stdout.replace('\r\n', '\n')
                if actual.endswith('\n'):
                    actual = actual[:-1]
                if actual == expected:
                    passed += 1
            else:
                feedback = 'passed' if passed == total else 'wrong_answer'
    except (TimeoutError, HTTPException) as exc:
        state = 'error'
        feedback = 'timeout' if isinstance(exc, TimeoutError) or getattr(exc, 'status_code', 0) == 504 else 'service_unavailable'
    updated = await storage('PATCH', query, {'state': state, 'passed_count': passed,
        'feedback': feedback, 'updated_at': datetime.now(timezone.utc).isoformat()})
    if not isinstance(updated, list) or len(updated) != 1:
        raise HTTPException(502, 'Result could not be saved; retrieve the existing attempt')
    return response_record(updated[0])
