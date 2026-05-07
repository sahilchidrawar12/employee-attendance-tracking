import time
from datetime import datetime


class ActivityTracker:
    def __init__(self, idle_threshold_seconds: int = 300):
        self.idle_threshold_seconds = idle_threshold_seconds
        self.last_activity_timestamp = time.time()
        self.active_seconds = 0
        self.idle_seconds = 0
        self.is_idle = False

    def record_activity(self):
        self.last_activity_timestamp = time.time()
        if self.is_idle:
            self.is_idle = False

    def tick(self):
        now = time.time()
        elapsed = now - self.last_activity_timestamp
        if elapsed >= self.idle_threshold_seconds:
            self.is_idle = True
            self.idle_seconds += 1
        else:
            self.active_seconds += 1

    def get_summary(self):
        return {
            'active_minutes': self.active_seconds // 60,
            'idle_minutes': self.idle_seconds // 60,
            'is_idle': self.is_idle,
            'last_activity_at': datetime.utcnow().isoformat() + 'Z'
        }
