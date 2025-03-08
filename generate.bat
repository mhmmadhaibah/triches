@echo off

"%ProgramFiles%\Python313\python.exe" "%~dp0\code\generator.py" > "%~dp0\code\serials.result.txt"

start "" "%~dp0\code\serials.result.txt"

exit
