@echo off
REM PC Agent Installation Script for Windows
REM This script installs the PC Agent as a Windows Service that auto-starts on boot

echo 🔧 PC Agent Installation Script for Windows
echo ============================================

setlocal enabledelayedexpansion

REM Configuration
set "AGENT_DIR=%~dp0"
set "AGENT_DIR=%AGENT_DIR:~0,-1%"
set "VENV_DIR=%AGENT_DIR%\venv"
set "SERVICE_NAME=PCAgentService"
set "PYTHON_EXE=%VENV_DIR%\Scripts\python.exe"
set "MAIN_SCRIPT=%AGENT_DIR%\src\main.py"
set "LOG_DIR=%AGENT_DIR%\logs"
set "NSSM_URL=https://nssm.cc/release/nssm-2.24.zip"
set "NSSM_ZIP=%TEMP%\nssm.zip"
set "NSSM_DIR=%TEMP%\nssm"

REM Colors (using Windows color codes)
set "GREEN=[92m"
set "RED=[91m"
set "YELLOW=[93m"
set "BLUE=[94m"
set "RESET=[0m"

:log_info
echo [INFO] %~1
goto :eof

:log_success
echo [SUCCESS] %~1
goto :eof

:log_warning
echo [WARNING] %~1
goto :eof

:log_error
echo [ERROR] %~1
goto :eof

:check_dependencies
call :log_info Checking dependencies...

REM Check Python 3
python --version >nul 2>&1
if %errorlevel% neq 0 (
    call :log_error Python is not installed. Please install Python 3.7+ first.
    exit /b 1
)

for /f "tokens=2" %%i in ('python --version 2^>^&1') do set PYTHON_VERSION=%%i
call :log_success Python %PYTHON_VERSION% found

REM Check if running as administrator
net session >nul 2>&1
if %errorlevel% neq 0 (
    call :log_error This script must be run as Administrator.
    call :log_info Right-click the script and select "Run as administrator"
    exit /b 1
)
call :log_success Running as Administrator
goto :eof

:download_nssm
call :log_info Downloading NSSM (Non-Sucking Service Manager)...

if not exist "%NSSM_DIR%\nssm-2.24\win64\nssm.exe" (
    powershell -Command "& {Invoke-WebRequest -Uri '%NSSM_URL%' -OutFile '%NSSM_ZIP%'}"
    if %errorlevel% neq 0 (
        call :log_error Failed to download NSSM
        exit /b 1
    )

    powershell -Command "& {Expand-Archive -Path '%NSSM_ZIP%' -DestinationPath '%NSSM_DIR%' -Force}"
    if %errorlevel% neq 0 (
        call :log_error Failed to extract NSSM
        exit /b 1
    )
)
call :log_success NSSM downloaded and extracted
goto :eof

:setup_virtual_environment
call :log_info Setting up Python virtual environment...

if not exist "%VENV_DIR%" (
    python -m venv "%VENV_DIR%"
    if %errorlevel% neq 0 (
        call :log_error Failed to create virtual environment
        exit /b 1
    )
    call :log_success Virtual environment created
) else (
    call :log_warning Virtual environment already exists
)

REM Activate virtual environment and install dependencies
call "%VENV_DIR%\Scripts\activate.bat"
python -m pip install --upgrade pip
pip install -r "%AGENT_DIR%\requirements.txt"
if %errorlevel% neq 0 (
    call :log_error Failed to install dependencies
    exit /b 1
)
call :log_success Dependencies installed
goto :eof

:create_log_directory
call :log_info Creating log directory...

if not exist "%LOG_DIR%" (
    mkdir "%LOG_DIR%"
)
call :log_success Log directory created: %LOG_DIR%
goto :eof

:install_service
call :log_info Installing PC Agent as Windows service...

REM Stop existing service if running
sc stop "%SERVICE_NAME%" >nul 2>&1
sc delete "%SERVICE_NAME%" >nul 2>&1
timeout /t 2 /nobreak >nul

REM Install service using NSSM
"%NSSM_DIR%\nssm-2.24\win64\nssm.exe" install "%SERVICE_NAME%" "%PYTHON_EXE%" "%MAIN_SCRIPT%"
if %errorlevel% neq 0 (
    call :log_error Failed to install service
    exit /b 1
)

REM Configure service
"%NSSM_DIR%\nssm-2.24\win64\nssm.exe" set "%SERVICE_NAME%" AppDirectory "%AGENT_DIR%"
"%NSSM_DIR%\nssm-2.24\win64\nssm.exe" set "%SERVICE_NAME%" AppStdout "%LOG_DIR%\agent.out.log"
"%NSSM_DIR%\nssm-2.24\win64\nssm.exe" set "%SERVICE_NAME%" AppStderr "%LOG_DIR%\agent.err.log"
"%NSSM_DIR%\nssm-2.24\win64\nssm.exe" set "%SERVICE_NAME%" AppRotateFiles 1
"%NSSM_DIR%\nssm-2.24\win64\nssm.exe" set "%SERVICE_NAME%" AppRotateOnline 1
"%NSSM_DIR%\nssm-2.24\win64\nssm.exe" set "%SERVICE_NAME%" AppRotateSeconds 86400
"%NSSM_DIR%\nssm-2.24\win64\nssm.exe" set "%SERVICE_NAME%" Description "PC Agent for Attendance Tracking"

REM Set service to auto-start
sc config "%SERVICE_NAME%" start= auto
if %errorlevel% neq 0 (
    call :log_warning Failed to set auto-start, continuing...
)

REM Start the service
sc start "%SERVICE_NAME%"
if %errorlevel% neq 0 (
    call :log_error Failed to start service
    exit /b 1
)

call :log_success PC Agent service installed and started
goto :eof

:create_uninstall_script
call :log_info Creating uninstall script...

(
echo @echo off
echo REM PC Agent Uninstall Script for Windows
echo.
echo echo 🗑️  Uninstalling PC Agent...
echo.
echo REM Stop and remove the service
echo sc stop "%SERVICE_NAME%" ^>nul 2^>^&1
echo sc delete "%SERVICE_NAME%" ^>nul 2^>^&1
echo.
echo REM Remove virtual environment ^(optional^)
echo echo Note: To remove the virtual environment, delete the 'venv' folder manually.
echo.
echo echo ✅ PC Agent uninstalled successfully
echo pause
) > "%AGENT_DIR%\uninstall.bat"

call :log_success Uninstall script created: %AGENT_DIR%\uninstall.bat
goto :eof

:test_agent
call :log_info Testing PC Agent...

REM Run the test script
call "%VENV_DIR%\Scripts\activate.bat"
"%PYTHON_EXE%" "%AGENT_DIR%\test_agent.py" >nul 2>&1
if %errorlevel% neq 0 (
    call :log_error PC Agent tests failed
    exit /b 1
)
call :log_success PC Agent tests passed
goto :eof

:show_status
echo.
echo 📊 PC Agent Status
echo ==================
echo.
sc query "%SERVICE_NAME%" | findstr "STATE" >nul 2>&1
if %errorlevel% equ 0 (
    echo ✓ Service Status: Running
) else (
    echo ✗ Service Status: Not running
)

if exist "%LOG_DIR%\agent.out.log" (
    echo ✓ Log File: %LOG_DIR%\agent.out.log
) else (
    echo ⚠ Log File: Not created yet
)
echo.
echo 🔧 Management Commands:
echo Start:  sc start "%SERVICE_NAME%"
echo Stop:   sc stop "%SERVICE_NAME%"
echo Status: sc query "%SERVICE_NAME%"
echo Logs:   notepad "%LOG_DIR%\agent.out.log"
echo Uninstall: "%AGENT_DIR%\uninstall.bat"
goto :eof

:main
echo.
call :check_dependencies
call :download_nssm
call :setup_virtual_environment
call :create_log_directory
call :install_service
call :create_uninstall_script
call :test_agent

echo.
call :log_success PC Agent installation completed successfully!
echo.
echo 🎉 The PC Agent will now:
echo    • Auto-start when Windows boots
echo    • Run as a background service
echo    • Restart automatically if it crashes
echo    • Log activity to %LOG_DIR%\
echo.

call :show_status
goto :eof

REM Run main function
call :main %*