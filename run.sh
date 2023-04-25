#!/bin/bash

# Usage: ./script.sh [start|stop|daemon] [port_number] [upstream_pattern] [upstream_host]
DAEMON=false
ACTION=$1
PORT=$2
UPSTREAM_PATTERN=$3
UPSTREAM_HOST=$4

# Check if a valid port number was provided
if [[ -z "$PORT" ]] || ! [[ "$PORT" =~ ^[0-9]+$ ]]; then
  PORT=80
fi

# Determine the operating system and architecture
OS=$(uname | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m)
PWD=$(pwd)

# Set the directory where the Caddy binary is located
CADDY_DIR=$PWD

# Execute sed command
sed "s|PORT|$PORT|g" Caddyfile.template >Caddyfile.stage1
sed "s|UPSTREAM_HOST|$UPSTREAM_HOST|g" Caddyfile.stage1 >Caddyfile.stage2
sed "s|UPSTREAM_PATTERN|$UPSTREAM_PATTERN|g" Caddyfile.stage2 >Caddyfile.stage3
cp Caddyfile.stage3 Caddyfile
rm -rf Caddyfile.stage*

# Check the operating system and architecture, and set the appropriate permissions for the Caddy binary
if [[ "$OS" == "darwin" && "$ARCH" == "arm64" ]]; then
  CADDY_PROCESS_NAME="caddy_darwin_arm64"
elif [[ "$OS" == "darwin" && "$ARCH" == "x86_64" ]]; then
  CADDY_PROCESS_NAME="caddy_darwin_amd64"
elif [[ "$OS" == "linux" && "$ARCH" == "x86_64" ]]; then
  CADDY_PROCESS_NAME="caddy_linux_amd64"
else
  echo "Unsupported operating system or architecture"
  exit 1
fi

CADDY_BINARY=$CADDY_DIR"/"$CADDY_PROCESS_NAME
chmod +x $CADDY_BINARY

# Function to start Caddy
start_caddy() {
  if pgrep -x "$CADDY_PROCESS_NAME" >/dev/null; then
    echo "Caddy is already running."
  else
    if [ "$DAEMON" = true ]; then
      nohup $CADDY_BINARY run 2>&1 >spit.log &
    else
      $CADDY_BINARY run
    fi
    echo "Caddy started."
  fi
}

# Function to stop Caddy
stop_caddy() {
  if pgrep -x "$CADDY_PROCESS_NAME" >/dev/null; then
    pkill -x "$CADDY_PROCESS_NAME"
    echo "Caddy stopped."
  else
    echo "Caddy is not running."
  fi
}

# Perform the specified action
case "$ACTION" in
start)
  start_caddy
  ;;
stop)
  stop_caddy
  ;;
daemon)
  DAEMON=true
  start_caddy
  ;;
*)
  echo "Usage: $0 [start|stop|daemon] port_number upstream_pattern] [upstream_host"
  ;;
esac
