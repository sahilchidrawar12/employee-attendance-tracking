#!/usr/bin/env python3
"""Test script for PC Agent functionality."""

import sys
import os
import tempfile
import sqlite3
from datetime import datetime, timezone
from pathlib import Path

# Add src to path
sys.path.insert(0, 'src')

def test_imports():
    """Test module imports."""
    print("\n=== Testing Module Imports ===")
    try:
        from agent import PcAgent
        from tracker.activity_tracker import ActivityTracker
        from service.service import initialize_database, insert_activity_summary
        print("✓ All imports successful")
        return True
    except Exception as e:
        print(f"✗ Import failed: {e}")
        return False

def test_database():
    """Test database operations."""
    print("\n=== Testing Database Operations ===")
    # Create temp directory for test
    with tempfile.TemporaryDirectory() as tmpdir:
        os.chdir(tmpdir)
        try:
            from service.service import initialize_database, insert_activity_summary
            
            # Initialize database
            initialize_database()
            print("✓ Database initialized successfully")
            
            # Insert test data
            now_iso = datetime.now(timezone.utc).isoformat().replace('+00:00', 'Z')
            insert_activity_summary(
                session_start=now_iso,
                session_end=now_iso,
                active_minutes=30,
                idle_minutes=10
            )
            print("✓ Activity summary inserted successfully")
            
            # Query test data
            conn = sqlite3.connect('agent_data.db')
            cursor = conn.cursor()
            cursor.execute('SELECT COUNT(*) FROM pc_activity')
            count = cursor.fetchone()[0]
            conn.close()
            print(f"✓ Database query successful - {count} records in pc_activity table")
            return True
        except Exception as e:
            print(f"✗ Database test failed: {e}")
            import traceback
            traceback.print_exc()
            return False
        finally:
            os.chdir('..')

def test_activity_tracker():
    """Test activity tracker."""
    print("\n=== Testing Activity Tracker ===")
    try:
        from tracker.activity_tracker import ActivityTracker
        
        tracker = ActivityTracker()
        print(f"✓ ActivityTracker initialized")
        
        # Simulate activity
        tracker.record_activity()
        tracker.tick()
        summary = tracker.get_summary()
        
        print(f"✓ Activity tracking works:")
        print(f"  - Active minutes: {summary['active_minutes']}")
        print(f"  - Idle minutes: {summary['idle_minutes']}")
        print(f"  - Is idle: {summary['is_idle']}")
        return True
    except Exception as e:
        print(f"✗ Activity tracker test failed: {e}")
        import traceback
        traceback.print_exc()
        return False

def test_agent_initialization():
    """Test agent initialization."""
    print("\n=== Testing Agent Initialization ===")
    try:
        from agent import PcAgent
        import tempfile
        
        with tempfile.TemporaryDirectory() as tmpdir:
            token_file = os.path.join(tmpdir, 'token.json')
            agent = PcAgent(token_file)
            
            print(f"✓ Agent initialized:")
            print(f"  - Hardware ID: {agent.hardware_id}")
            print(f"  - PC Name: {agent.pc_name}")
            print(f"  - Token: {agent.token[:16]}...")
            print(f"  - API Base: {os.environ.get('API_BASE_URL', 'http://localhost:8080/api')}")
            return True
    except Exception as e:
        print(f"✗ Agent initialization failed: {e}")
        import traceback
        traceback.print_exc()
        return False

def main():
    """Run all tests."""
    print("\n" + "="*50)
    print("PC AGENT VERIFICATION")
    print("="*50)
    
    results = []
    results.append(("Imports", test_imports()))
    results.append(("Activity Tracker", test_activity_tracker()))
    results.append(("Agent Initialization", test_agent_initialization()))
    results.append(("Database", test_database()))
    
    print("\n" + "="*50)
    print("TEST RESULTS SUMMARY")
    print("="*50)
    for test_name, result in results:
        status = "✓ PASS" if result else "✗ FAIL"
        print(f"{status}: {test_name}")
    
    passed = sum(1 for _, result in results if result)
    total = len(results)
    print(f"\nTotal: {passed}/{total} tests passed")
    
    if passed == total:
        print("\n✓ All PC Agent components are working correctly!")
        return 0
    else:
        print(f"\n✗ {total - passed} test(s) failed. Please review the errors above.")
        return 1

if __name__ == '__main__':
    sys.exit(main())
