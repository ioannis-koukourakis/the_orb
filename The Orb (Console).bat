@echo off
setlocal

set "script_dir=%~dp0"
cd /d "%script_dir%bin"

set "exe_path=The Orb.exe"
if not exist "%exe_path%" (
    echo Release executable not found: %cd%\%exe_path%
    exit /b 1
)

start "" "%exe_path%" CONSOLE

exit /b 0
