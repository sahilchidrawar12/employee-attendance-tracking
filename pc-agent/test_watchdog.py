#!/usr/bin/env python3
"""
Test script for PC Agent Watchdog
Tests the anti-tampering functionality
"""

import os
import sys
import time
import signal
import psutil
from pathlib import Path

def test_watchdog_basic():
    """Test basic watchdog functionality"""
    print("🧪 Testing PC Agent Watchdog...")

    # Import the watchdog
    sys.path.insert(0, str(Path(__file__).parent / 'src'))
    from watchdog import PcAgentWatchdog

    watchdog = PcAgentWatchdog()

    # Test 1: Check if agent is not running initially
    print("Test 1: Checking initial state...")
    assert not watchdog.is_agent_running(), "Agent should not be running initially"
    print("✅ Agent correctly detected as not running")

    # Test 2: Start the agent
    print("Test 2: Starting agent...")
    success = watchdog.start_agent()
    assert success, "Failed to start agent"
    print("✅ Agent start command issued")

    # Wait longer for the process to actually start
    print("Waiting for agent to initialize...")
    time.sleep(5)

    # Test 3: Check if agent is running
    print("Test 3: Checking if agent is running...")
    is_running = watchdog.is_agent_running()
    if not is_running:
        print("Debug: Checking subprocess status...")
        if watchdog.agent_process:
            poll_result = watchdog.agent_process.poll()
            print(f"  Subprocess poll result: {poll_result}")
            if poll_result is None:
                print("  Subprocess is still running according to poll()")
            else:
                print(f"  Subprocess exited with code: {poll_result}")
        else:
            print("  No subprocess reference")

        print("Debug: Checking running processes...")
        import psutil
        for proc in psutil.process_iter(['pid', 'name', 'cmdline']):
            try:
                if proc.info['name'] and 'python' in proc.info['name'].lower():
                    cmdline = proc.info['cmdline']
                    if cmdline:
                        print(f"  Python process: PID {proc.info['pid']}, CMD: {' '.join(cmdline)}")
            except:
                pass
    assert is_running, "Agent should be running"
    print("✅ Agent correctly detected as running")

    # Test 4: Stop the agent
    print("Test 4: Stopping agent...")
    watchdog.stop_agent()
    time.sleep(2)
    print("✅ Agent stopped")

    # Test 5: Verify agent is stopped
    print("Test 5: Verifying agent is stopped...")
    assert not watchdog.is_agent_running(), "Agent should be stopped"
    print("✅ Agent correctly detected as stopped")

    print("\n🎉 All watchdog tests passed!")

def test_anti_tamper():
    """Test anti-tampering by trying to kill the process"""
    print("\n🛡️  Testing Anti-Tamper Protection...")

    sys.path.insert(0, str(Path(__file__).parent / 'src'))
    from watchdog import PcAgentWatchdog

    watchdog = PcAgentWatchdog()

    # Start the agent
    print("Starting agent for anti-tamper test...")
    watchdog.start_agent()
    time.sleep(3)

    # Get the process
    agent_pid = watchdog.agent_process.pid
    print(f"Agent PID: {agent_pid}")

    # Try to kill it externally (simulate tampering)
    print("Simulating external kill attempt...")
    try:
        if os.name == 'nt':
            os.system(f"taskkill /PID {agent_pid} /F >nul 2>&1")
        else:
            os.kill(agent_pid, signal.SIGKILL)
    except:
        pass

    time.sleep(2)

    # The watchdog should detect this and restart
    print("Checking if watchdog restarted the agent...")
    assert watchdog.is_agent_running(), "Watchdog should have restarted the agent"
    print("✅ Anti-tamper protection working - agent restarted automatically!")

    # Clean up
    watchdog.stop_agent()

def main():
    print("🚀 PC Agent Watchdog Test Suite")
    print("=" * 40)

    try:
        test_watchdog_basic()
        test_anti_tamper()

        print("\n" + "=" * 40)
        print("🎯 ALL TESTS PASSED!")
        print("✅ Anti-tamper system is working correctly")
        print("✅ PC Agent will automatically restart if stopped")
        print("=" * 40)

    except Exception as e:
        print(f"\n❌ Test failed: {e}")
        sys.exit(1)

if __name__ == '__main__':
    main()