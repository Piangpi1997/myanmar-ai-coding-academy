import asyncio
import base64
from typing import Annotated
from urllib.parse import urlparse
from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel, ConfigDict, Field
from .auth import current_user
from .config import settings
from .limits import limiter
from .upstream import request_json

router = APIRouter(prefix='/api/v1/code', tags=['Sandbox execution'])


class RunInput(BaseModel):
    model_config = ConfigDict(extra='forbid')
    code: str = Field(min_length=1, max_length=16000)
    stdin: str = Field(default='', max_length=4000)


class RunOutput(BaseModel):
    status_id: int
    status: str
    stdout: str
    stderr: str
    compile_output: str
    truncated: bool = False


def decoded(value):
    raw = base64.b64decode(value or '', validate=True)
    return raw[:16000].decode('utf-8', errors='replace'), len(raw) > 16000


@router.post('/run', response_model=RunOutput)
async def run(payload: RunInput, auth: Annotated[tuple[str, str], Depends(current_user)]):
    url = settings.judge0_url.rstrip('/')
    parsed = urlparse(url)
    if not settings.judge0_sandbox_verified or parsed.scheme != 'https' or not parsed.hostname or parsed.username or parsed.query or parsed.fragment:
        raise HTTPException(503, 'Verified HTTPS sandbox is not configured')
    limiter.check(auth[0], 'run', minute=10, day=200)
    headers = {'X-Auth-Token': settings.judge0_auth_token} if settings.judge0_auth_token else {}
    body = {
        'source_code': base64.b64encode(payload.code.encode()).decode(),
        'stdin': base64.b64encode(payload.stdin.encode()).decode(),
        'language_id': settings.judge0_python_id,
        'cpu_time_limit': 2, 'wall_time_limit': 5, 'memory_limit': 65536,
        'stack_limit': 8192, 'max_processes_and_or_threads': 1,
        'max_file_size': 64, 'enable_network': False,
        'redirect_stderr_to_stdout': False,
    }
    try:
        async with asyncio.timeout(22):
            job = await request_json('POST', url + '/submissions?base64_encoded=true&wait=false', headers=headers, body=body)
            from uuid import UUID
            token = str(UUID(job['token']))
            for _ in range(18):
                await asyncio.sleep(0.5)
                result = await request_json('GET', url + '/submissions/' + token + '?base64_encoded=true&fields=status,stdout,stderr,compile_output', headers=headers)
                status_id = result['status']['id']
                if status_id in (1, 2):
                    continue
                out, out_cut = decoded(result.get('stdout'))
                err, err_cut = decoded(result.get('stderr'))
                comp, comp_cut = decoded(result.get('compile_output'))
                return RunOutput(status_id=status_id, status=str(result['status']['description'])[:120], stdout=out, stderr=err,
                                 compile_output=comp, truncated=out_cut or err_cut or comp_cut)
        raise HTTPException(504, 'Sandbox result not ready; execution may still complete')
    except TimeoutError:
        raise HTTPException(504, 'Sandbox timed out; execution may still complete') from None
    except (KeyError, ValueError, TypeError):
        raise HTTPException(502, 'Invalid sandbox response') from None
