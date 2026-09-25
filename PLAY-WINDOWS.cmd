@echo off
set "ASHEN_GODOT=E:\Godot\4.7.1\Godot_v4.7.1-stable_win64_console.exe"
if not exist "%ASHEN_GODOT%" (
  echo Godot 4.7.1 tidak ditemukan. Buka project.godot melalui Godot.
  pause
  exit /b 1
)
"%ASHEN_GODOT%" --path "%~dp0." --editor --headless --import --quit
start "Ashen Covenant" "%ASHEN_GODOT%" --path "%~dp0."
