@echo off

rem Usage: script.bat [start|stop|daemon] [port_number] [upstream_pattern] [upstream_host]
set DAEMON=false
set ACTION=%1
set PORT=%2
if "%PORT%"=="" set PORT=80
set UPSTREAM_PATTERN=%3
if "%UPSTREAM_PATTERN%"=="" set UPSTREAM_PATTERN=blackhole
set UPSTREAM_HOST=%4
if "%UPSTREAM_HOST%"=="" set UPSTREAM_HOST=1.1.1.1

rem Determine the operating system and architecture
for /f "tokens=*" %%a in ('wmic os get osarchitecture ^| findstr /r /c:"[0-9]"') do set ARCH=%%a
set PWD=%cd%

rem Set the directory where the Caddy binary is located
set CADDY_DIR=%PWD%
set STATIC=%CADDY_DIR%\static

rem Test if UPSTREAM_HOST is a domain or IP address
rem Execute sed command
echo %UPSTREAM_HOST% | findstr /r /c:"^[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*$" >nul
if %errorlevel%==0 (
  sed -e "s|PORT|%PORT%|g" -e "s|STATIC|%STATIC%|g" -e "s|UPSTREAM_HOST|%UPSTREAM_HOST%|g" -e "s|UPSTREAM_PATTERN|%UPSTREAM_PATTERN%|g" caddy-file.json.template-ip.json >caddy-file.json
) else (
  sed -e "s|PORT|%PORT%|g" -e "s|STATIC|%STATIC%|g" -e "s|UPSTREAM_HOST|%UPSTREAM_HOST%|g" -e "s|UPSTREAM_PATTERN|%UPSTREAM_PATTERN%|g" caddy-file.json.template-address.json >caddy-file.json
)

rem Check the operating system and architecture, and set the appropriate permissions for the Caddy binary
if "%ARCH%"=="64-bit" (
  set CADDY_PROCESS_NAME=caddy_windows_amd64.exe
) else (
  echo Unsupported architecture
  exit /b 1
)

set CADDY_BINARY=%CADDY_DIR%\%CADDY_PROCESS_NAME%

rem Function to start Caddy
:start_caddy
tasklist /fi "imagename eq %CADDY_PROCESS_NAME%" |find /i "%CADDY_PROCESS_NAME%" >nul
if not errorlevel 1 (
  echo Caddy is already running.
) else (
  if "%DAEMON%"=="true" (
    start /b %CADDY_BINARY% run --config=./caddy-file.json 2>&1 >spit.log
  ) else (
    %CADDY_BINARY% run --config=./caddy-file.json
  )
  echo Caddy started.
)
goto :eof

rem Function to stop Caddy
:stop_caddy
tasklist /fi "imagename eq %CADDY_PROCESS_NAME%" |find /i "%CADDY_PROCESS_NAME%" >nul
if not errorlevel 1 (
  taskkill /f /im "%CADDY_PROCESS_NAME%"
  echo Caddy stopped.
) else (
  echo Caddy is not running.
)
goto :eof

rem Perform the specified action
if /i "%ACTION%"=="start" (
  call :start_caddy
) else if /i "%ACTION%"=="stop" (
  call :stop_caddy
) else if /i "%ACTION%"=="daemon" (
  set DAEMON=true
  call :start_caddy
) else (
  echo Usage: %0 [start|stop|daemon] [port_number] [upstream_pattern] [upstream_host]
)
