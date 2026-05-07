import json
import os
import platform
import requests
import logging
from uuid import uuid4
from requests.adapters import HTTPAdapter
from urllib3.util.retry import Retry

logger = logging.getLogger(__name__)

API_BASE = os.environ.get('API_BASE_URL', 'http://localhost:8080/api')


def get_hardware_id():
    return platform.node() or str(uuid4())


def ensure_token_file(token_file_path: str):
    if os.path.exists(token_file_path):
        try:
            with open(token_file_path, 'r', encoding='utf-8') as token_file:
                token_data = json.load(token_file)
                if token_data.get('token'):
                    return token_data['token']
        except Exception as e:
            logger.warning(f"Failed to read token file: {e}")
    
    token = str(uuid4())
    try:
        os.makedirs(os.path.dirname(token_file_path) or '.', exist_ok=True)
        with open(token_file_path, 'w', encoding='utf-8') as token_file:
            json.dump({'token': token}, token_file)
    except Exception as e:
        logger.warning(f"Failed to write token file: {e}")
    return token


class PcAgent:
    def __init__(self, token_file_path: str):
        self.token_file_path = token_file_path
        self.agent_id = None
        self.hardware_id = get_hardware_id()
        self.pc_name = platform.node()
        self.token = ensure_token_file(token_file_path)
        self.session = self._create_session()
    
    def _create_session(self):
        """Create a requests session with retry logic."""
        session = requests.Session()
        retry_strategy = Retry(
            total=3,
            backoff_factor=1,
            status_forcelist=[429, 500, 502, 503, 504],
            allowed_methods=["HEAD", "GET", "OPTIONS", "POST"]
        )
        adapter = HTTPAdapter(max_retries=retry_strategy)
        session.mount("http://", adapter)
        session.mount("https://", adapter)
        return session

    def register(self):
        """Register the PC agent with the backend."""
        payload = {
            'token': self.token,
            'hardwareId': self.hardware_id,
            'pcName': self.pc_name,
            'osVersion': platform.platform()
        }
        try:
            response = self.session.post(
                f"{API_BASE}/agent/register",
                json=payload,
                timeout=10
            )
            response.raise_for_status()
            data = response.json().get('data', {})
            self.agent_id = data.get('agentId')
            logger.info(f"Agent registered with ID: {self.agent_id}")
            return data
        except requests.exceptions.RequestException as e:
            logger.error(f"Registration request failed: {e}")
            raise

    def heartbeat(self):
        """Send heartbeat to backend."""
        if not self.agent_id:
            raise RuntimeError('Agent is not registered')
        
        payload = {
            'agentId': self.agent_id,
            'timestamp': self._now_iso()
        }
        try:
            response = self.session.post(
                f"{API_BASE}/agent/heartbeat",
                json=payload,
                timeout=10
            )
            response.raise_for_status()
            logger.debug("Heartbeat sent successfully")
            return response.json()
        except requests.exceptions.RequestException as e:
            logger.error(f"Heartbeat request failed: {e}")
            raise

    def _now_iso(self):
        from datetime import datetime, timezone
        return datetime.now(timezone.utc).isoformat().replace('+00:00', 'Z')
