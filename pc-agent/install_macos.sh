#!/bin/bash
# PC Agent Installation Script for macOS
# This script installs the PC Agent as a background service that auto-starts on login

set -e

echo "🔧 PC Agent Installation Script for macOS"
echo "=========================================="

# Configuration
AGENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VENV_DIR="$AGENT_DIR/venv"
PLIST_FILE="$HOME/Library/LaunchAgents/com.attendancetracker.pcagent.plist"
LOG_DIR="$HOME/Library/Logs/PC-Agent"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

check_dependencies() {
    log_info "Checking dependencies..."

    # Check Python 3
    if ! command -v python3 &> /dev/null; then
        log_error "Python 3 is not installed. Please install Python 3.7+ first."
        exit 1
    fi

    PYTHON_VERSION=$(python3 -c 'import sys; print(".".join(map(str, sys.version_info[:2])))')
    if [[ "$(printf '%s\n' "$PYTHON_VERSION" "3.7" | sort -V | head -n1)" != "3.7" ]]; then
        log_error "Python 3.7+ is required. Current version: $PYTHON_VERSION"
        exit 1
    fi

    log_success "Python $PYTHON_VERSION found"
}

setup_virtual_environment() {
    log_info "Setting up Python virtual environment..."

    if [ ! -d "$VENV_DIR" ]; then
        python3 -m venv "$VENV_DIR"
        log_success "Virtual environment created"
    else
        log_warning "Virtual environment already exists"
    fi

    # Activate virtual environment and install dependencies
    source "$VENV_DIR/bin/activate"
    pip install --upgrade pip
    pip install -r "$AGENT_DIR/requirements.txt"

    log_success "Dependencies installed"
}

create_log_directory() {
    log_info "Creating log directory..."

    mkdir -p "$LOG_DIR"
    log_success "Log directory created: $LOG_DIR"
}

create_launch_agent() {
    log_info "Creating Launch Agent plist..."

    # Create the plist file
    cat > "$PLIST_FILE" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.attendancetracker.pcagent</string>

    <key>ProgramArguments</key>
    <array>
        <string>$VENV_DIR/bin/python3</string>
        <string>$AGENT_DIR/src/main.py</string>
    </array>

    <key>WorkingDirectory</key>
    <string>$AGENT_DIR</string>

    <key>StandardOutPath</key>
    <string>$LOG_DIR/agent.out.log</string>

    <key>StandardErrorPath</key>
    <string>$LOG_DIR/agent.err.log</string>

    <key>EnvironmentVariables</key>
    <dict>
        <key>PATH</key>
        <string>$VENV_DIR/bin:/usr/local/bin:/usr/bin:/bin</string>
        <key>PYTHONPATH</key>
        <string>$AGENT_DIR/src</string>
    </dict>

    <key>RunAtLoad</key>
    <true/>

    <key>KeepAlive</key>
    <true/>

    <key>ProcessType</key>
    <string>Background</string>

    <key>Nice</key>
    <integer>10</integer>
</dict>
</plist>
EOF

    log_success "Launch Agent plist created: $PLIST_FILE"
}

load_launch_agent() {
    log_info "Loading Launch Agent..."

    # Unload if already loaded
    launchctl unload "$PLIST_FILE" 2>/dev/null || true

    # Load the new agent
    launchctl load "$PLIST_FILE"

    # Check if it's running
    if launchctl list | grep -q "com.attendancetracker.pcagent"; then
        log_success "PC Agent loaded and running"
    else
        log_error "Failed to load PC Agent"
        exit 1
    fi
}

create_uninstall_script() {
    log_info "Creating uninstall script..."

    cat > "$AGENT_DIR/uninstall.sh" << 'EOF'
#!/bin/bash
# PC Agent Uninstall Script for macOS

echo "🗑️  Uninstalling PC Agent..."

# Stop and unload the launch agent
launchctl unload "$HOME/Library/LaunchAgents/com.attendancetracker.pcagent.plist" 2>/dev/null || true

# Remove the plist file
rm -f "$HOME/Library/LaunchAgents/com.attendancetracker.pcagent.plist"

# Remove logs
rm -rf "$HOME/Library/Logs/PC-Agent"

echo "✅ PC Agent uninstalled successfully"
echo "Note: The agent directory and virtual environment are still intact."
echo "To completely remove, delete the pc-agent directory manually."
EOF

    chmod +x "$AGENT_DIR/uninstall.sh"
    log_success "Uninstall script created: $AGENT_DIR/uninstall.sh"
}

test_agent() {
    log_info "Testing PC Agent..."

    # Run the test script
    if "$VENV_DIR/bin/python3" "$AGENT_DIR/test_agent.py" > /dev/null 2>&1; then
        log_success "PC Agent tests passed"
    else
        log_error "PC Agent tests failed"
        exit 1
    fi
}

show_status() {
    echo ""
    echo "📊 PC Agent Status"
    echo "=================="

    if launchctl list | grep -q "com.attendancetracker.pcagent"; then
        echo -e "${GREEN}✓ Service Status:${NC} Running"
    else
        echo -e "${RED}✗ Service Status:${NC} Not running"
    fi

    if [ -f "$LOG_DIR/agent.out.log" ]; then
        echo -e "${GREEN}✓ Log File:${NC} $LOG_DIR/agent.out.log"
    else
        echo -e "${YELLOW}⚠ Log File:${NC} Not created yet"
    fi

    echo ""
    echo "🔧 Management Commands:"
    echo "Start:  launchctl load $PLIST_FILE"
    echo "Stop:   launchctl unload $PLIST_FILE"
    echo "Status: launchctl list | grep pcagent"
    echo "Logs:   tail -f $LOG_DIR/agent.out.log"
    echo "Uninstall: $AGENT_DIR/uninstall.sh"
}

main() {
    echo ""
    check_dependencies
    setup_virtual_environment
    create_log_directory
    create_launch_agent
    load_launch_agent
    create_uninstall_script
    test_agent

    echo ""
    log_success "PC Agent installation completed successfully!"
    echo ""
    echo "🎉 The PC Agent will now:"
    echo "   • Auto-start when you log in to macOS"
    echo "   • Run in the background continuously"
    echo "   • Restart automatically if it crashes"
    echo "   • Log activity to $LOG_DIR/"
    echo ""

    show_status
}

# Run main function
main "$@"