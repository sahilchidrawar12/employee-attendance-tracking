#!/bin/bash
# PC Agent Installation Script for Linux
# This script installs the PC Agent as a systemd service that auto-starts on boot

set -e

echo "🔧 PC Agent Installation Script for Linux"
echo "=========================================="

# Configuration
AGENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VENV_DIR="$AGENT_DIR/venv"
SERVICE_FILE="/etc/systemd/system/pc-agent.service"
USER_SERVICE_FILE="$HOME/.config/systemd/user/pc-agent.service"
LOG_DIR="$HOME/.local/share/pc-agent/logs"

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

    # Check if running on Linux
    if [[ "$OSTYPE" != "linux-gnu"* ]]; then
        log_error "This script is for Linux systems only."
        exit 1
    fi

    # Check Python 3
    if ! command -v python3 &> /dev/null; then
        log_error "Python 3 is not installed. Please install Python 3.7+ first."
        log_info "Ubuntu/Debian: sudo apt install python3 python3-venv"
        log_info "CentOS/RHEL: sudo yum install python3 python3-venv"
        exit 1
    fi

    PYTHON_VERSION=$(python3 -c 'import sys; print(".".join(map(str, sys.version_info[:2])))')
    if [[ "$(printf '%s\n' "$PYTHON_VERSION" "3.7" | sort -V | head -n1)" != "3.7" ]]; then
        log_error "Python 3.7+ is required. Current version: $PYTHON_VERSION"
        exit 1
    fi

    log_success "Python $PYTHON_VERSION found"

    # Check systemd
    if ! command -v systemctl &> /dev/null; then
        log_error "systemd is not available. This script requires systemd."
        exit 1
    fi

    log_success "systemd found"
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

create_service_file() {
    log_info "Creating systemd service file..."

    # Determine if we should use system or user service
    if [[ $EUID -eq 0 ]]; then
        # Running as root, use system service
        SERVICE_FILE_PATH="$SERVICE_FILE"
        USER_OPTION=""
        log_info "Installing as system service (requires root)"
    else
        # Running as user, use user service
        mkdir -p "$(dirname "$USER_SERVICE_FILE")"
        SERVICE_FILE_PATH="$USER_SERVICE_FILE"
        USER_OPTION="--user"
        log_info "Installing as user service"
    fi

    # Create the service file
    cat > "$SERVICE_FILE_PATH" << EOF
[Unit]
Description=PC Agent for Attendance Tracking
After=network.target
Wants=network.target

[Service]
Type=simple
ExecStart=$VENV_DIR/bin/python3 $AGENT_DIR/src/main.py
WorkingDirectory=$AGENT_DIR
Restart=always
RestartSec=10
Environment=PYTHONPATH=$AGENT_DIR/src
Environment=PATH=$VENV_DIR/bin:/usr/local/bin:/usr/bin:/bin
StandardOutput=append:$LOG_DIR/agent.out.log
StandardError=append:$LOG_DIR/agent.err.log

# Security settings
NoNewPrivileges=yes
ProtectHome=yes
ProtectSystem=strict
ReadWritePaths=$AGENT_DIR $LOG_DIR
PrivateTmp=yes

[Install]
WantedBy=multi-user.target
EOF

    log_success "Service file created: $SERVICE_FILE_PATH"
}

enable_service() {
    log_info "Enabling and starting PC Agent service..."

    if [[ $EUID -eq 0 ]]; then
        USER_OPTION=""
    else
        USER_OPTION="--user"
    fi

    # Reload systemd daemon
    systemctl $USER_OPTION daemon-reload

    # Enable the service
    systemctl $USER_OPTION enable pc-agent

    # Start the service
    systemctl $USER_OPTION start pc-agent

    # Check if it's running
    sleep 2
    if systemctl $USER_OPTION is-active --quiet pc-agent; then
        log_success "PC Agent service is running"
    else
        log_error "Failed to start PC Agent service"
        log_info "Check logs: journalctl $USER_OPTION -u pc-agent -f"
        exit 1
    fi
}

create_uninstall_script() {
    log_info "Creating uninstall script..."

    if [[ $EUID -eq 0 ]]; then
        USER_OPTION=""
    else
        USER_OPTION="--user"
    fi

    cat > "$AGENT_DIR/uninstall.sh" << EOF
#!/bin/bash
# PC Agent Uninstall Script for Linux

echo "🗑️  Uninstalling PC Agent..."

# Stop and disable the service
systemctl $USER_OPTION stop pc-agent 2>/dev/null || true
systemctl $USER_OPTION disable pc-agent 2>/dev/null || true

# Remove the service file
if [[ $EUID -eq 0 ]]; then
    rm -f /etc/systemd/system/pc-agent.service
else
    rm -f "\$HOME/.config/systemd/user/pc-agent.service"
fi

# Reload systemd
systemctl $USER_OPTION daemon-reload 2>/dev/null || true

# Remove logs
rm -rf "\$HOME/.local/share/pc-agent"

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

    if [[ $EUID -eq 0 ]]; then
        USER_OPTION=""
    else
        USER_OPTION="--user"
    fi

    if systemctl $USER_OPTION is-active --quiet pc-agent 2>/dev/null; then
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
    if [[ $EUID -eq 0 ]]; then
        echo "Start:   sudo systemctl start pc-agent"
        echo "Stop:    sudo systemctl stop pc-agent"
        echo "Status:  sudo systemctl status pc-agent"
        echo "Logs:    sudo journalctl -u pc-agent -f"
    else
        echo "Start:   systemctl --user start pc-agent"
        echo "Stop:    systemctl --user stop pc-agent"
        echo "Status:  systemctl --user status pc-agent"
        echo "Logs:    journalctl --user -u pc-agent -f"
    fi
    echo "Uninstall: $AGENT_DIR/uninstall.sh"
}

main() {
    echo ""
    check_dependencies
    setup_virtual_environment
    create_log_directory
    create_service_file
    enable_service
    create_uninstall_script
    test_agent

    echo ""
    log_success "PC Agent installation completed successfully!"
    echo ""
    echo "🎉 The PC Agent will now:"
    echo "   • Auto-start when Linux boots"
    echo "   • Run as a background service"
    echo "   • Restart automatically if it crashes"
    echo "   • Log activity to $LOG_DIR/"
    echo ""

    show_status
}

# Run main function
main "$@"