import os
import sys
import time
import logging
from pathlib import Path

# Try to load environment variables from .env file
try:
    from dotenv import load_dotenv
    load_dotenv()
except ImportError:
    pass

# Setup logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.StreamHandler(sys.stdout),
        logging.FileHandler('pc_agent.log')
    ]
)
logger = logging.getLogger(__name__)

from agent import PcAgent
from tracker.activity_tracker import ActivityTracker
from service.service import initialize_database, insert_activity_summary

TOKEN_PATH = os.environ.get('PC_AGENT_TOKEN_PATH', 'agent_token.json')
HEARTBEAT_INTERVAL_SECONDS = 300


def main():
    logger.info("Initializing PC Agent...")
    
    try:
        initialize_database()
        logger.info("Database initialized successfully")
    except Exception as e:
        logger.error(f"Failed to initialize database: {e}", exc_info=True)
        sys.exit(1)
    
    agent = PcAgent(TOKEN_PATH)
    registration_successful = False
    
    try:
        registration = agent.register()
        logger.info(f"Agent registered successfully: {registration}")
        registration_successful = True
    except Exception as exc:
        logger.warning(f"Agent registration failed (will retry on heartbeat): {exc}")

    tracker = ActivityTracker(idle_threshold_seconds=300)
    logger.info('PC Agent started. Running activity loop...')
    logger.info(f'API Base URL: {os.environ.get("API_BASE_URL", "http://localhost:8080/api")}')

    heartbeat_timer = 0
    try:
        while True:
            tracker.tick()
            time.sleep(60)
            heartbeat_timer += 60
            
            if tracker.is_idle:
                logger.debug('User is idle')
            else:
                logger.debug('User is active')

            try:
                summary = tracker.get_summary()
                insert_activity_summary(
                    session_start=summary['last_activity_at'],
                    session_end=summary['last_activity_at'],
                    active_minutes=summary['active_minutes'],
                    idle_minutes=summary['idle_minutes'],
                )
            except Exception as e:
                logger.error(f"Failed to save activity summary: {e}")

            if heartbeat_timer >= HEARTBEAT_INTERVAL_SECONDS:
                heartbeat_timer = 0
                try:
                    if not registration_successful:
                        registration = agent.register()
                        registration_successful = True
                        logger.info(f"Agent registered on heartbeat: {registration}")
                    
                    heartbeat_response = agent.heartbeat()
                    logger.info(f"Heartbeat success")
                except Exception as exc:
                    logger.error(f"Heartbeat failed: {exc}")
    except KeyboardInterrupt:
        logger.info('Agent shutting down.')
    except Exception as e:
        logger.error(f"Unexpected error: {e}", exc_info=True)
        sys.exit(1)


if __name__ == '__main__':
    main()
