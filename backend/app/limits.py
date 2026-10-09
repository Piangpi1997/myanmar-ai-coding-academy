"""Bounded, single-process quotas. Deploy one worker until a shared limiter is added."""
import time
from collections import OrderedDict, deque
from fastapi import HTTPException


class Limiter:
    def __init__(self):
        self.windows = OrderedDict()

    def check(self, user: str, feature: str, minute: int, day: int):
        now = time.monotonic()
        key = (user, feature)
        # Expire idle entries without allowing a client to evict active quotas.
        while self.windows:
            first, events = next(iter(self.windows.items()))
            if events[-1] > now - 86400:
                break
            del self.windows[first]
        if key not in self.windows and len(self.windows) >= 10000:
            raise HTTPException(503, 'Quota service busy')
        events = self.windows.setdefault(key, deque())
        while events and events[0] <= now - 86400:
            events.popleft()
        if len(events) >= day or sum(t > now - 60 for t in events) >= minute:
            raise HTTPException(429, 'Usage limit reached', headers={'Retry-After': '60'})
        events.append(now)
        self.windows.move_to_end(key)


limiter = Limiter()
