@echo off
setlocal
set PYTHONUTF8=1
chcp 65001 >nul
cd /d "%~dp0"
if exist "D:\workforce\anaconda\python.exe" (
    "D:\workforce\anaconda\python.exe" "%~dp0encounter_3d_demo.py" %*
) else (
    python "%~dp0encounter_3d_demo.py" %*
)
if errorlevel 1 pause
