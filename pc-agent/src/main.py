import os
import time
from pathlib import Path

from agent import PcAgent
from tracker.activity_tracker import ActivityTracker
from service.service import initialize_database, insert_activity_summary

TOKEN_PATH = os.environ.get('PC_AGENT_TOKEN_PATH', 'agent_token.json')
HEARTBEAT_INTERVAL_SECONDS = 300


def main():
    initialize_database()
    agent = PcAgent(TOKEN_PATH)
    try:
        registration = agent.register()
        print(f"Registered agent: {registration}")
    except Exception as exc:
        print(f"Registration failed: {exc}")

    tracker = ActivityTracker(idle_threshold_seconds=300)
    print('PC Agent started. Running activity loop...')

    heartbeat_timer = 0
    try:
        while True:
            tracker.tick()
            time.sleep(60)
            heartbeat_timer += 60
            if tracker.is_idle:
                print('User is idle')
            else:
                print('User is active')

            summary = tracker.get_summary()
            insert_activity_summary(
                session_start=summary['last_activity_at'],
                session_end=summary['last_activity_at'],
                active_minutes=summary['active_minutes'],
                idle_minutes=summary['idle_minutes'],
            )

            if heartbeat_timer >= HEARTBEAT_INTERVAL_SECONDS:
                heartbeat_timer = 0
                try:
                    heartbeat_response = agent.heartbeat()
                    print(f"Heartbeat success: {heartbeat_response}")
                except Exception as exc:
                    print(f"Heartbeat failed: {exc}")
    except KeyboardInterrupt:
        print('Agent shutting down.')


if __name__ == '__main__':
    main()
