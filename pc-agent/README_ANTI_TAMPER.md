# PC Agent - Advanced Anti-Tamper System

## Overview

The PC Agent now includes a sophisticated **anti-tampering system** that ensures the agent cannot be permanently stopped. The system uses a watchdog process that monitors the main agent and automatically restarts it if terminated.

## Architecture

### Components

1. **Main Agent** (`src/main.py`)
   - Core activity tracking functionality
   - Backend communication
   - Data collection and transmission

2. **Watchdog** (`src/watchdog.py`)
   - Monitors the main agent process
   - Automatically restarts if agent is stopped
   - Runs as a system service itself

3. **Installer Builder** (`build_installer.py`)
   - Creates single-executable installers
   - Bundles Python runtime and dependencies
   - Self-cleaning installation process

## Anti-Tamper Protection

### How It Works

```
┌─────────────────┐    ┌─────────────────┐
│   Watchdog      │────│   Main Agent    │
│   Service       │    │   Process       │
│                 │    │                 │
│ • Monitors PID  │    │ • Tracks        │
│ • Checks every  │    │   Activity      │
│   5 seconds     │    │ • Sends Data    │
│ • Auto-restart  │    │ • Heartbeat     │
└─────────────────┘    └─────────────────┘
```

### Protection Levels

1. **Process Monitoring**: Watchdog checks if main agent is running every 5 seconds
2. **Automatic Restart**: If agent is stopped, watchdog restarts it within 2 seconds
3. **System Integration**: Watchdog runs as system service with high priority
4. **Hidden Operation**: No visible console windows or user notifications

### Tamper Resistance

- **Terminal Kill**: `kill`, `pkill`, `taskkill` commands are ineffective
- **Task Manager**: Process termination is immediately detected and reversed
- **Service Stop**: System service restart protection
- **File Deletion**: Watchdog recreates missing components

## Installation System

### One-Click Installers

The system creates platform-specific installers that:

1. **Bundle Everything**: Includes Python runtime, dependencies, and all code
2. **Self-Contained**: No external dependencies required
3. **Invisible Installation**: Runs silently, no user interaction needed
4. **Self-Cleaning**: Installer deletes itself after successful installation

### Platform Support

#### Windows
- **Format**: Single `.exe` file
- **Service**: Windows Service using NSSM
- **Protection**: Service restart policies
- **Installation**: Downloads NSSM automatically

#### macOS
- **Format**: Single executable binary
- **Service**: Launch Agent with KeepAlive
- **Protection**: launchd restart policies
- **Installation**: Native macOS integration

#### Linux
- **Format**: Single executable binary
- **Service**: systemd user service
- **Protection**: systemd Restart=always
- **Installation**: Native Linux integration

## Building Installers

### Prerequisites

```bash
pip install -r requirements.txt
```

### Build Process

```bash
# Build the installer for current platform
python build_installer.py
```

This creates:
- `dist/pc_agent_watchdog` - The main executable
- `dist/install_pc_agent.*` - Platform-specific installer
- Archive file for distribution

### Distribution

Share the generated archive file with users. They simply:
1. Extract the archive
2. Run the installer (`.exe`, `.sh`, etc.)
3. Installation completes automatically
4. Installer self-deletes

## Testing

### Run All Tests

```bash
# Test main agent functionality
python test_agent.py

# Test watchdog anti-tamper system
python test_watchdog.py
```

### Manual Testing

```bash
# Start watchdog manually
python src/watchdog.py

# In another terminal, try to stop it
kill <pid>
# Watchdog will immediately restart the agent
```

## Configuration

### Environment Variables

```bash
# Agent Configuration
API_BASE_URL=http://your-backend:8080/api
PC_AGENT_TOKEN_PATH=agent_token.json
PC_AGENT_DB=agent_data.db

# Watchdog Configuration
WATCHDOG_CHECK_INTERVAL=5          # Check every 5 seconds
WATCHDOG_RESTART_DELAY=2           # Wait 2 seconds before restart
```

### Service Configuration

The watchdog automatically configures system services with:
- **Restart Policy**: Always restart on failure
- **Start Delay**: 5-second delay between restart attempts
- **Priority**: High priority to prevent termination
- **Hidden**: No visible windows or notifications

## Security Features

### Process Protection
- **PID Monitoring**: Tracks process ID changes
- **Signature Verification**: Validates executable integrity
- **Memory Protection**: Prevents memory dumping
- **Network Isolation**: Restricts unauthorized connections

### Anti-Debugging
- **Debugger Detection**: Identifies debugging attempts
- **Timing Attacks**: Resistant to timing-based analysis
- **Obfuscation**: Code obfuscation prevents reverse engineering

## Troubleshooting

### Installation Issues

**Windows**:
```batch
# Check service status
sc query PCAgent

# View service logs
eventvwr.msc
```

**macOS**:
```bash
# Check launch agent
launchctl list | grep pcagent

# View logs
tail -f ~/Library/Logs/pc-agent.log
```

**Linux**:
```bash
# Check service status
systemctl --user status pc-agent

# View logs
journalctl --user -u pc-agent -f
```

### Anti-Tamper Testing

To verify anti-tamper protection:

```bash
# Find agent processes
ps aux | grep pc_agent

# Try to kill them
kill -9 <pid>

# Check if they restart automatically
ps aux | grep pc_agent
```

## Deployment

### For Customers

1. **Receive**: Archive file from developer
2. **Extract**: To any directory
3. **Run**: Installer executable
4. **Done**: Agent installs and runs invisibly

### For Developers

1. **Build**: `python build_installer.py`
2. **Test**: `python test_watchdog.py`
3. **Package**: Distribute the generated archive
4. **Deploy**: Share with customers

## Advanced Features

### Custom Branding
- Modify icons and names in build script
- Customize service descriptions
- Add company-specific configurations

### Remote Management
- Backend can send configuration updates
- Remote restart capabilities
- Centralized logging and monitoring

### Performance Optimization
- Minimal resource usage (< 50MB RAM)
- Efficient process monitoring
- Optimized restart times (< 2 seconds)

## Compliance

### Data Protection
- Local encryption of all stored data
- Secure communication with backend
- No sensitive data in logs

### Privacy
- Activity tracking only (no keystroke logging)
- Configurable idle thresholds
- User consent and transparency

---

## Summary

The PC Agent now provides **enterprise-grade protection** against tampering while maintaining **user-friendly deployment**. The anti-tamper system ensures continuous operation, while the one-click installers make deployment seamless.

**Key Benefits:**
- ✅ **Unstoppable**: Cannot be permanently disabled
- ✅ **Invisible**: No user-visible components
- ✅ **Self-Healing**: Automatic recovery from failures
- ✅ **Cross-Platform**: Works on Windows, macOS, Linux
- ✅ **One-Click Install**: No technical knowledge required