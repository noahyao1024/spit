@echo off

set "PORT=%1"
if "%PORT%"=="" set "PORT=80"

set "STATIC=%2"
if "%STATIC%"=="" set "STATIC=./static"

caddy_windows_amd64.exe file-server --browse --listen :%PORT% --root %STATIC%