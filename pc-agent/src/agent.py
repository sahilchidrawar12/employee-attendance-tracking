import json
import os
import platform
import requests
from uuid import uuid4

API_BASE = os.environ.get('API_BASE_URL', 'https://api.attendancetracker.com/v1')


def get_hardware_id():
    return platform.node() or str(uuid4())


def ensure_token_file(token_file_path: str):
    if os.path.exists(token_file_path):
        with open(token_file_path, 'r', encoding='utf-8') as token_file:
            token_data = json.load(token_file)
            if token_data.get('token'):
                return token_data['token']
    token = str(uuid4())
    os.makedirs(os.path.dirname(token_file_path) or '.', exist_ok=True)
    with open(token_file_path, 'w', encoding='utf-8') as token_file:
        json.dump({'token': token}, token_file)
    return token


class PcAgent:
    def __init__(self, token_file_path: str):
        self.token_file_path = token_file_path
        self.agent_id = None
        self.hardware_id = get_hardware_id()
        self.pc_name = platform.node()
        self.token = ensure_token_file(token_file_path)

    def register(self):
        payload = {
            'token': self.token,
            'hardwareId': self.hardware_id,
            'pcName': self.pc_name,
            'osVersion': platform.platform()
        }
        response = requests.post(f"{API_BASE}/agent/register", json=payload)
        response.raise_for_status()
        data = response.json().get('data', {})
        self.agent_id = data.get('agentId')
        return data

    def heartbeat(self):
        if not self.agent_id:
            raise RuntimeError('Agent is not registered')
        payload = {
            'agentId': self.agent_id,
            'timestamp': self._now_iso()
        }
        response = requests.post(f"{API_BASE}/agent/heartbeat", json=payload)
        response.raise_for_status()
        return response.json()

    def _now_iso(self):
        from datetime import datetime
        return datetime.utcnow().isoformat() + 'Z'
