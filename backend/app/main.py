"""Authenticated academy API: user JWT + Supabase RLS, transient BYOK, remote runner."""
from typing import Annotated
import httpx
from fastapi import Depends, FastAPI, HTTPException, Path, Request
from fastapi.exceptions import RequestValidationError
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from pydantic import BaseModel, Field
from starlette.types import ASGIApp, Receive, Scope, Send
from .auth import current_user
from .config import settings
from .ai import router as ai_router
from .runner import router as runner_router


class BodyLimit:
    def __init__(self, app: ASGIApp):
        self.app = app

    async def __call__(self, scope: Scope, receive: Receive, send: Send):
        if scope['type'] != 'http':
            return await self.app(scope, receive, send)
        body = bytearray()
        while True:
            message = await receive()
            if message['type'] == 'http.disconnect':
                return
            body.extend(message.get('body', b''))
            if len(body) > 65536:
                return await JSONResponse({'detail': 'Request too large'}, status_code=413)(scope, receive, send)
            if not message.get('more_body', False):
                break
        delivered = False
        async def replay():
            nonlocal delivered
            if delivered:
                return await receive()
            delivered = True
            return {'type': 'http.request', 'body': bytes(body), 'more_body': False}
        await self.app(scope, replay, send)


class ProgressInput(BaseModel):
    lesson_id: str = Field(pattern=r'^[a-z0-9-]{1,64}$')
    completed: bool = True


class ProgressRecord(ProgressInput):
    updated_at: str | None = None


app = FastAPI(title='Myanmar AI Coding Academy API', version='0.2.0')
app.add_middleware(BodyLimit)
if settings.allowed_origins:
    app.add_middleware(CORSMiddleware, allow_origins=settings.allowed_origins.split(','),
                       allow_methods=['GET', 'PUT', 'POST'], allow_headers=['Authorization', 'Content-Type', 'X-AI-Key'])
app.include_router(ai_router)
app.include_router(runner_router)


@app.middleware('http')
async def private_responses(request: Request, call_next):
    response = await call_next(request)
    response.headers['Cache-Control'] = 'no-store'
    response.headers['X-Content-Type-Options'] = 'nosniff'
    return response


@app.exception_handler(RequestValidationError)
async def validation_error(request: Request, exc: RequestValidationError):
    # Pydantic defaults echo rejected inputs. Never echo user code or accidentally pasted keys.
    return JSONResponse(status_code=422, content={'detail': 'Invalid request fields'})


@app.get('/health')
async def health():
    return {'status': 'ok'}


async def supabase_request(method: str, path: str, token: str, json_body: dict | None = None):
    headers = {'apikey': settings.supabase_anon_key, 'Authorization': f'Bearer {token}',
               'Content-Type': 'application/json', 'Prefer': 'return=representation,resolution=merge-duplicates'}
    try:
        async with httpx.AsyncClient(timeout=12, follow_redirects=False, trust_env=False) as client:
            response = await client.request(method, settings.supabase_url.rstrip('/') + '/rest/v1/' + path,
                                            headers=headers, json=json_body)
            if response.status_code in (401, 403):
                raise HTTPException(401, 'Session expired or access denied')
            if response.status_code == 409:
                raise HTTPException(404, 'Lesson not found')
            response.raise_for_status()
            return response.json()
    except (httpx.HTTPError, ValueError):
        raise HTTPException(502, 'Progress storage unavailable') from None


@app.get('/api/v1/progress', response_model=list[ProgressRecord])
async def list_progress(auth: Annotated[tuple[str, str], Depends(current_user)]):
    user_id, token = auth
    # Explicit filter plus independently enforced RLS. Never accept a client-supplied user id.
    return await supabase_request('GET', f'lesson_progress?user_id=eq.{user_id}&select=lesson_id,completed,updated_at&order=updated_at.desc', token)


@app.put('/api/v1/progress/{lesson_id}', response_model=ProgressRecord)
async def save_progress(lesson_id: Annotated[str, Path(pattern=r'^[a-z0-9-]{1,64}$')],
                        auth: Annotated[tuple[str, str], Depends(current_user)]):
    user_id, token = auth
    result = await supabase_request('POST', 'lesson_progress?on_conflict=user_id,lesson_id', token,
                                    {'user_id': user_id, 'lesson_id': lesson_id, 'completed': True})
    if not isinstance(result, list) or not result:
        raise HTTPException(502, 'No progress returned')
    return result[0]
