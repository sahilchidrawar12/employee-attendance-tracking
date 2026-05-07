#!/usr/bin/env python3
"""
PC Agent Builder - Creates single-executable installers for all platforms
This script bundles Python runtime, dependencies, and creates platform-specific installers
"""

import os
import sys
import shutil
import subprocess
import platform
from pathlib import Path

class PcAgentBuilder:
    def __init__(self):
        self.root_dir = Path(__file__).parent
        self.src_dir = self.root_dir / 'src'
        self.build_dir = self.root_dir / 'build'
        self.dist_dir = self.root_dir / 'dist'
        self.spec_file = self.build_dir / 'pc_agent.spec'

    def clean_build(self):
        """Clean previous build artifacts"""
        print("🧹 Cleaning previous builds...")
        for dir_path in [self.build_dir, self.dist_dir]:
            if dir_path.exists():
                shutil.rmtree(dir_path)
        (self.build_dir / 'watchdog').mkdir(parents=True, exist_ok=True)
        (self.dist_dir).mkdir(parents=True, exist_ok=True)

    def create_spec_file(self):
        """Create PyInstaller spec file for the watchdog"""
        spec_content = f'''
# -*- mode: python ; coding: utf-8 -*-

import os
import sys
from pathlib import Path

# Get the directory where this spec file is located
spec_dir = Path(SPEC)
src_dir = spec_dir.parent / 'src'

a = Analysis(
    ['src/watchdog.py'],
    pathex=[str(spec_dir.parent)],
    binaries=[],
    datas=[
        ('src', 'src'),
        ('.env', '.'),
    ],
    hiddenimports=[
        'dotenv',
        'cryptography',
        'psutil',
        'requests',
        'flask',
        'sqlite3',
    ],
    hookspath=[],
    hooksconfig={{}},
    runtime_hooks=[],
    excludes=[],
    win_no_prefer_redirects=False,
    win_private_assemblies=False,
    cipher=None,
    noarchive=False,
)

pyz = PYZ(a.pure, a.zipped_data, cipher=None)

exe = EXE(
    pyz,
    a.scripts,
    a.binaries,
    a.zipfiles,
    a.datas,
    [],
    name='pc_agent_watchdog',
    debug=False,
    bootloader_ignore_signals=False,
    strip=False,
    upx=True,
    upx_exclude=[],
    runtime_tmpdir=None,
    console=False,
    disable_windowed_traceback=False,
    argv_emulation=False,
    target_arch=None,
    codesign_identity=None,
    entitlements_file=None,
    icon=None,
)
'''
        self.spec_file.write_text(spec_content)
        print(f"📝 Created spec file: {self.spec_file}")

    def build_executable(self):
        """Build the executable using PyInstaller"""
        print("🔨 Building executable...")

        cmd = [
            sys.executable, '-m', 'PyInstaller',
            '--clean',
            '--noconfirm',
            '--onefile',
            '--windowed',  # No console window
            '--hidden-import=dotenv',
            '--hidden-import=cryptography',
            '--hidden-import=psutil',
            '--hidden-import=requests',
            '--hidden-import=flask',
            '--hidden-import=sqlite3',
            '--add-data', f'{self.src_dir}{os.pathsep}src',
            '--add-data', f'{self.root_dir}/.env{os.pathsep}.',
            '--name', 'pc_agent_watchdog',
            str(self.src_dir / 'watchdog.py')
        ]

        result = subprocess.run(cmd, cwd=self.root_dir, capture_output=True, text=True)
        if result.returncode != 0:
            print(f"❌ Build failed: {result.stderr}")
            sys.exit(1)

        print("✅ Executable built successfully")

    def create_installer_script(self):
        """Create the self-deleting installer script"""
        system = platform.system().lower()

        if system == 'windows':
            self._create_windows_installer()
        elif system == 'darwin':
            self._create_macos_installer()
        else:  # Linux and others
            self._create_linux_installer()

    def _create_windows_installer(self):
        """Create Windows installer batch script"""
        installer_content = '''@echo off
setlocal enabledelayedexpansion

echo ========================================
echo PC Agent Installation
echo ========================================
echo.

set "INSTALL_DIR=%APPDATA%\\PCAgent"
set "EXE_NAME=pc_agent_watchdog.exe"
set "EXE_PATH=%~dp0%EXE_NAME%"
set "NSSM_URL=https://nssm.cc/release/nssm-2.24.zip"
set "NSSM_ZIP=%TEMP%\\nssm.zip"
set "NSSM_DIR=%TEMP%\\nssm"

echo [1/6] Creating installation directory...
if not exist "%INSTALL_DIR%" mkdir "%INSTALL_DIR%"

echo [2/6] Copying agent executable...
copy "%EXE_PATH%" "%INSTALL_DIR%\\%EXE_NAME%" >nul

echo [3/6] Downloading NSSM service manager...
powershell -Command "& {Invoke-WebRequest -Uri '%NSSM_URL%' -OutFile '%NSSM_ZIP%'}"
if errorlevel 1 (
    echo ERROR: Failed to download NSSM
    goto :cleanup
)

echo [4/6] Extracting NSSM...
powershell -Command "& {Add-Type -AssemblyName System.IO.Compression.FileSystem; [System.IO.Compression.ZipFile]::ExtractToDirectory('%NSSM_ZIP%', '%NSSM_DIR%')}"
if errorlevel 1 (
    echo ERROR: Failed to extract NSSM
    goto :cleanup
)

echo [5/6] Installing PC Agent service...
"%NSSM_DIR%\\nssm-2.24\\win64\\nssm.exe" install PCAgent "%INSTALL_DIR%\\%EXE_NAME%"
"%NSSM_DIR%\\nssm-2.24\\win64\\nssm.exe" set PCAgent AppDirectory "%INSTALL_DIR%"
"%NSSM_DIR%\\nssm-2.24\\win64\\nssm.exe" set PCAgent AppRestartDelay 5000
"%NSSM_DIR%\\nssm-2.24\\win64\\nssm.exe" start PCAgent

echo [6/6] Starting service...
net start PCAgent

echo.
echo ========================================
echo Installation completed successfully!
echo ========================================
echo.
echo The PC Agent is now running as a system service.
echo It will automatically restart if stopped.
echo.
echo Service Name: PCAgent
echo Installation Directory: %INSTALL_DIR%
echo.

:cleanup
echo Cleaning up installation files...
if exist "%NSSM_ZIP%" del "%NSSM_ZIP%"
if exist "%NSSM_DIR%" rmdir /s /q "%NSSM_DIR%"
if exist "%EXE_PATH%" del "%EXE_PATH%"

echo Installation files cleaned up.
echo Press any key to exit...
pause >nul

REM Self-delete this script
(goto) 2>nul & del "%~f0"
'''
        installer_path = self.dist_dir / 'install_pc_agent.bat'
        installer_path.write_text(installer_content)
        print(f"📦 Created Windows installer: {installer_path}")

    def _create_macos_installer(self):
        """Create macOS installer script"""
        installer_content = '''#!/bin/bash
set -e

echo "========================================="
echo "PC Agent Installation for macOS"
echo "========================================="
echo

INSTALL_DIR="$HOME/Library/Application Support/PCAgent"
EXE_NAME="pc_agent_watchdog"
EXE_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$EXE_NAME"
PLIST_PATH="$HOME/Library/LaunchAgents/com.attendancetracker.pcagent.plist"

echo "[1/4] Creating installation directory..."
mkdir -p "$INSTALL_DIR"

echo "[2/4] Copying agent executable..."
cp "$EXE_PATH" "$INSTALL_DIR/$EXE_NAME"
chmod +x "$INSTALL_DIR/$EXE_NAME"

echo "[3/4] Creating Launch Agent plist..."
cat > "$PLIST_PATH" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.attendancetracker.pcagent</string>
    <key>ProgramArguments</key>
    <array>
        <string>$INSTALL_DIR/$EXE_NAME</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
    <key>StandardOutPath</key>
    <string>$HOME/Library/Logs/pc-agent.log</string>
    <key>StandardErrorPath</key>
    <string>$HOME/Library/Logs/pc-agent.err.log</string>
    <key>WorkingDirectory</key>
    <string>$INSTALL_DIR</string>
</dict>
</plist>
EOF

echo "[4/4] Loading Launch Agent..."
launchctl unload "$PLIST_PATH" 2>/dev/null || true
launchctl load "$PLIST_PATH"

echo
echo "========================================="
echo "Installation completed successfully!"
echo "========================================="
echo
echo "The PC Agent is now running as a Launch Agent."
echo "It will automatically restart if stopped."
echo
echo "Installation Directory: $INSTALL_DIR"
echo "Launch Agent: $PLIST_PATH"
echo

# Clean up installation files
echo "Cleaning up installation files..."
rm -f "$EXE_PATH"
rm -f "$0"

echo "Installation files cleaned up."
echo "Installation complete!"
'''
        installer_path = self.dist_dir / 'install_pc_agent.sh'
        installer_path.write_text(installer_content)
        os.chmod(installer_path, 0o755)
        print(f"📦 Created macOS installer: {installer_path}")

    def _create_linux_installer(self):
        """Create Linux installer script"""
        installer_content = '''#!/bin/bash
set -e

echo "========================================="
echo "PC Agent Installation for Linux"
echo "========================================="
echo

INSTALL_DIR="$HOME/.local/share/pc-agent"
EXE_NAME="pc_agent_watchdog"
EXE_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$EXE_NAME"
SERVICE_FILE="$HOME/.config/systemd/user/pc-agent.service"

echo "[1/4] Creating installation directory..."
mkdir -p "$INSTALL_DIR"

echo "[2/4] Copying agent executable..."
cp "$EXE_PATH" "$INSTALL_DIR/$EXE_NAME"
chmod +x "$INSTALL_DIR/$EXE_NAME"

echo "[3/4] Creating systemd user service..."
mkdir -p "$(dirname "$SERVICE_FILE")"

cat > "$SERVICE_FILE" << EOF
[Unit]
Description=PC Agent Watchdog
After=network.target
Wants=network.target

[Service]
Type=simple
ExecStart=$INSTALL_DIR/$EXE_NAME
Restart=always
RestartSec=5
WorkingDirectory=$INSTALL_DIR
StandardOutput=append:$HOME/.local/share/pc-agent/agent.log
StandardError=append:$HOME/.local/share/pc-agent/agent.err.log

[Install]
WantedBy=default.target
EOF

echo "[4/4] Enabling and starting service..."
systemctl --user daemon-reload
systemctl --user enable pc-agent
systemctl --user start pc-agent

echo
echo "========================================="
echo "Installation completed successfully!"
echo "========================================="
echo
echo "The PC Agent is now running as a systemd user service."
echo "It will automatically restart if stopped."
echo
echo "Installation Directory: $INSTALL_DIR"
echo "Service File: $SERVICE_FILE"
echo

# Clean up installation files
echo "Cleaning up installation files..."
rm -f "$EXE_PATH"
rm -f "$0"

echo "Installation files cleaned up."
echo "Installation complete!"
'''
        installer_path = self.dist_dir / 'install_pc_agent.sh'
        installer_path.write_text(installer_content)
        os.chmod(installer_path, 0o755)
        print(f"📦 Created Linux installer: {installer_path}")

    def create_archive(self):
        """Create a distributable archive"""
        system = platform.system().lower()
        if system == 'windows':
            archive_name = 'pc_agent_installer_windows.zip'
        elif system == 'darwin':
            archive_name = 'pc_agent_installer_macos.tar.gz'
        else:
            archive_name = 'pc_agent_installer_linux.tar.gz'

        archive_path = self.root_dir / archive_name

        print(f"📦 Creating distribution archive: {archive_name}")

        if system == 'windows':
            shutil.make_archive(str(archive_path.with_suffix('')), 'zip', self.dist_dir)
        else:
            import tarfile
            with tarfile.open(archive_path, 'w:gz') as tar:
                for file_path in self.dist_dir.rglob('*'):
                    tar.add(file_path, arcname=file_path.relative_to(self.dist_dir))

        print(f"✅ Distribution archive created: {archive_path}")

    def build(self):
        """Main build process"""
        print("🚀 Building PC Agent Installer")
        print("=" * 40)

        self.clean_build()
        self.create_spec_file()
        self.build_executable()
        self.create_installer_script()
        self.create_archive()

        print("\n" + "=" * 40)
        print("✅ Build completed successfully!")
        print("=" * 40)
        print("\nDistribution files created in ./dist/")
        print("Share the archive file with users for one-click installation.")

def main():
    builder = PcAgentBuilder()
    builder.build()

if __name__ == '__main__':
    main()