import os
import sqlite3
from datetime import datetime, timezone
from cryptography.fernet import Fernet

DB_PATH = os.environ.get('PC_AGENT_DB', 'agent_data.db')
KEY_PATH = os.environ.get('PC_AGENT_KEY', 'agent_key.bin')


def _load_key():
    if os.path.exists(KEY_PATH):
        with open(KEY_PATH, 'rb') as key_file:
            return key_file.read()
    key = Fernet.generate_key()
    with open(KEY_PATH, 'wb') as key_file:
        key_file.write(key)
    return key


def get_connection():
    key = _load_key()
    conn = sqlite3.connect(DB_PATH)
    conn.execute('PRAGMA journal_mode=WAL;')
    conn.execute('PRAGMA foreign_keys = ON;')
    return conn


def initialize_database():
    conn = get_connection()
    cursor = conn.cursor()
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS pc_activity (
            id TEXT PRIMARY KEY,
            session_start TEXT,
            session_end TEXT,
            active_minutes INTEGER,
            idle_minutes INTEGER,
            synced INTEGER DEFAULT 0,
            created_at TEXT
        )
    """)
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS app_usage (
            id TEXT PRIMARY KEY,
            app_name TEXT,
            window_title TEXT,
            duration_minutes INTEGER,
            is_productive INTEGER,
            date TEXT,
            synced INTEGER DEFAULT 0,
            created_at TEXT
        )
    """)
    conn.commit()
    conn.close()


def insert_activity_summary(session_start, session_end, active_minutes, idle_minutes):
    conn = get_connection()
    cursor = conn.cursor()
    cursor.execute(
        "INSERT INTO pc_activity (id, session_start, session_end, active_minutes, idle_minutes, synced, created_at) VALUES (?, ?, ?, ?, ?, 0, ?)",
        (str(datetime.now(timezone.utc).timestamp()), session_start, session_end, active_minutes, idle_minutes, datetime.now(timezone.utc).isoformat().replace('+00:00', 'Z'))
    )
    conn.commit()
    conn.close()
