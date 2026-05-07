#!/usr/bin/env python3
"""
PC Agent Watchdog - Monitors and restarts the main agent if stopped
This provides anti-tampering protection by ensuring the agent always runs
"""

import os
import sys
import time
import logging
import subprocess
import signal
import psutil
from pathlib import Path

# Setup minimal logging for watchdog
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - WATCHDOG - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('watchdog.log'),
        logging.StreamHandler(sys.stdout)
    ]
)
logger = logging.getLogger('watchdog')

class PcAgentWatchdog:
    def __init__(self):
        self.agent_process = None
        self.agent_script = Path(__file__).parent / 'main.py'
        self.python_executable = sys.executable
        self.venv_python = Path(__file__).parent / 'venv' / 'bin' / 'python3'
        if os.name == 'nt':
            self.venv_python = Path(__file__).parent / 'venv' / 'Scripts' / 'python.exe'
        self.check_interval = 5  # Check every 5 seconds
        self.restart_delay = 2   # Wait 2 seconds before restart

    def is_agent_running(self):
        """Check if the PC Agent main process is running"""
        try:
            # First check if we have a reference to our own subprocess
            if self.agent_process and self.agent_process.poll() is None:
                return True

            # Check system processes for python processes running main.py
            for proc in psutil.process_iter(['pid', 'name', 'cmdline']):
                try:
                    if proc.info['name'] and 'python' in proc.info['name'].lower():
                        cmdline = proc.info['cmdline']
                        if cmdline and len(cmdline) > 1:
                            cmdline_str = ' '.join(cmdline)
                            # Check if this process is running main.py and not the watchdog itself
                            if 'main.py' in cmdline_str and 'watchdog.py' not in cmdline_str and 'test_watchdog.py' not in cmdline_str:
                                logger.debug(f"Found agent process: PID {proc.info['pid']}, CMD: {cmdline_str}")
                                return True
                except (psutil.NoSuchProcess, psutil.AccessDenied):
                    continue

            return False
        except Exception as e:
            logger.error(f"Error checking agent status: {e}")
            return False

    def start_agent(self):
        """Start the PC Agent process"""
        try:
            logger.info("Starting PC Agent...")

            # Use virtual environment Python if available, otherwise system Python
            python_cmd = str(self.venv_python) if self.venv_python.exists() else self.python_executable
            logger.info(f"Using Python: {python_cmd}")

            # Set environment to hide console window on Windows
            env = os.environ.copy()
            env['PYTHONPATH'] = str(Path(__file__).parent / 'src')
            if os.name == 'nt':
                # Hide console window
                startupinfo = subprocess.STARTUPINFO()
                startupinfo.dwFlags |= subprocess.STARTF_USESHOWWINDOW
                startupinfo.wShowWindow = subprocess.SW_HIDE
                self.agent_process = subprocess.Popen(
                    [python_cmd, str(self.agent_script)],
                    stdout=subprocess.DEVNULL,
                    stderr=subprocess.DEVNULL,
                    startupinfo=startupinfo,
                    env=env
                )
            else:
                # For debugging, don't redirect output
                self.agent_process = subprocess.Popen(
                    [python_cmd, str(self.agent_script)],
                    env=env
                )

            logger.info(f"PC Agent started with PID: {self.agent_process.pid}")
            time.sleep(self.restart_delay)  # Give it time to start
            return True

        except Exception as e:
            logger.error(f"Failed to start PC Agent: {e}")
            return False

    def stop_agent(self):
        """Stop the PC Agent process"""
        try:
            if self.agent_process and self.agent_process.poll() is None:
                logger.info("Stopping PC Agent...")
                if os.name == 'nt':
                    self.agent_process.terminate()
                else:
                    os.killpg(os.getpgid(self.agent_process.pid), signal.SIGTERM)
                self.agent_process.wait(timeout=10)
                logger.info("PC Agent stopped")
        except Exception as e:
            logger.error(f"Error stopping agent: {e}")
            try:
                if os.name == 'nt':
                    self.agent_process.kill()
                else:
                    os.killpg(os.getpgid(self.agent_process.pid), signal.SIGKILL)
            except:
                pass

    def run(self):
        """Main watchdog loop"""
        logger.info("PC Agent Watchdog started")
        logger.info(f"Monitoring agent script: {self.agent_script}")
        logger.info(f"Python executable: {self.python_executable}")

        try:
            while True:
                if not self.is_agent_running():
                    logger.warning("PC Agent not running, restarting...")
                    self.start_agent()
                else:
                    # Agent is running, just log occasionally
                    pass

                time.sleep(self.check_interval)

        except KeyboardInterrupt:
            logger.info("Watchdog shutting down...")
            self.stop_agent()
        except Exception as e:
            logger.error(f"Watchdog error: {e}")
            self.stop_agent()
            sys.exit(1)

def main():
    watchdog = PcAgentWatchdog()
    watchdog.run()

if __name__ == '__main__':
    main()