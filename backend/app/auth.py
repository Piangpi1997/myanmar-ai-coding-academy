from functools import lru_cache
from typing import Annotated
from uuid import UUID

import jwt
from fastapi import Header, HTTPException
from jwt import PyJWKClient
from jwt.exceptions import PyJWKClientConnectionError
from starlette.concurrency import run_in_threadpool
from .config import settings


@lru_cache(maxsize=4)
def jwks_client(url):
    return PyJWKClient(url, cache_jwk_set=True, lifespan=300, timeout=8)


def verify_token(token):
    issuer = settings.supabase_url.rstrip('/') + '/auth/v1'
    header = jwt.get_unverified_header(token)
    if header.get('alg') not in ('RS256', 'ES256'):
        raise jwt.InvalidTokenError('Unsupported signing algorithm')
    key = jwks_client(issuer + '/.well-known/jwks.json').get_signing_key_from_jwt(token).key
    claims = jwt.decode(token, key, algorithms=['RS256', 'ES256'],
                        audience=settings.supabase_jwt_audience, issuer=issuer,
                        options={'require': ['exp', 'iat', 'sub', 'iss', 'aud', 'role']})
    if claims['role'] != 'authenticated':
        raise jwt.InvalidTokenError('User role required')
    return str(UUID(claims['sub']))


async def current_user(authorization: Annotated[str | None, Header()] = None):
    if not authorization or not authorization.startswith('Bearer '):
        raise HTTPException(401, 'Bearer token required')
    if not settings.supabase_url or not settings.supabase_anon_key:
        raise HTTPException(503, 'Supabase is not configured')
    token = authorization[7:]
    if not token or len(token) > 8192:
        raise HTTPException(401, 'Invalid or expired token')
    try:
        # PyJWKClient is synchronous; cache it and keep network I/O off the event loop.
        user_id = await run_in_threadpool(verify_token, token)
        return user_id, token
    except PyJWKClientConnectionError:
        raise HTTPException(503, 'Authentication service unavailable') from None
    except (jwt.PyJWTError, ValueError, TypeError, KeyError):
        raise HTTPException(401, 'Invalid or expired token') from None
