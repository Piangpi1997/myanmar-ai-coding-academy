"""Never forward upstream error bodies (they may contain credentials or code)."""
import json
import httpx
from fastapi import HTTPException


async def request_json(method, url, *, headers=None, body=None, max_bytes=131072, timeout=25):
    try:
        async with httpx.AsyncClient(timeout=timeout, follow_redirects=False, trust_env=False) as client:
            async with client.stream(method, url, headers=headers, json=body) as response:
                if response.status_code in (401, 403):
                    raise HTTPException(502, 'Provider rejected credentials or permissions')
                if response.status_code in (402, 429):
                    raise HTTPException(429, 'Provider quota or balance limit')
                if not 200 <= response.status_code < 300:
                    raise HTTPException(502, 'Upstream service unavailable')
                data = bytearray()
                async for chunk in response.aiter_bytes():
                    data.extend(chunk)
                    if len(data) > max_bytes:
                        raise HTTPException(502, 'Upstream response too large')
                return json.loads(data)
    except httpx.TimeoutException:
        raise HTTPException(504, 'Upstream timed out') from None
    except (httpx.HTTPError, ValueError):
        raise HTTPException(502, 'Upstream service unavailable') from None
