@echo off

:trigger
"%ProgramFiles%\Python313\python.exe" "%~dp0\code\explode.py"

echo.
set "consent2Refresh=" && set /p consent2Refresh=Do you want to trigger again? [Y/N]: 

if /i "%consent2Refresh%" == "Y" (
    cls & goto trigger
) else (
    type nul > "%~dp0\code\targets.txt"
)

pause
