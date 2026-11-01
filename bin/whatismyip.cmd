@echo off
REM whatismyip - cmd.exe wrapper that delegates to the PowerShell implementation.
setlocal
set SCRIPT_DIR=%~dp0
powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%whatismyip.ps1" %*
exit /b %ERRORLEVEL%
