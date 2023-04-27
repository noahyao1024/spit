#!/bin/bash

# Usage: ./script.sh [start|stop|daemon] [port_number] [upstream_pattern] [upstream_host]
DAEMON=false
ACTION=$1
PORT=${2:-80}
UPSTREAM_PATTERN=${3:-blackhole}
UPSTREAM_HOST=${4:-1.1.1.1}

# Determine the operating system and architecture
OS=$(uname | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m)
PWD=$(pwd)

# Set the directory where the Caddy binary is located
CADDY_DIR=$PWD
STATIC=$CADDY_DIR/static

# Test if UPSTREAM_HOST is a domain or IP address
# Execute sed command
if [[ $UPSTREAM_HOST =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  sed -e "s|PORT|$PORT|g" -e "s|STATIC|$STATIC|g" -e "s|UPSTREAM_HOST|$UPSTREAM_HOST|g" -e "s|UPSTREAM_PATTERN|$UPSTREAM_PATTERN|g" caddy-file.json.template-ip.json >caddy-file.json
else
  sed -e "s|PORT|$PORT|g" -e "s|STATIC|$STATIC|g" -e "s|UPSTREAM_HOST|$UPSTREAM_HOST|g" -e "s|UPSTREAM_PATTERN|$UPSTREAM_PATTERN|g" caddy-file.json.template-address.json >caddy-file.json
fi

# Check the operating system and architecture, and set the appropriate permissions for the Caddy binary
case "$OS" in
darwin)
  case "$ARCH" in
  arm64) CADDY_PROCESS_NAME="caddy_darwin_arm64" ;;
  x86_64) CADDY_PROCESS_NAME="caddy_darwin_amd64" ;;
  *)
    echo "Unsupported architecture"
    exit 1
    ;;
  esac
  ;;
linux)
  case "$ARCH" in
  x86_64) CADDY_PROCESS_NAME="caddy_linux_amd64" ;;
  *)
    echo "Unsupported architecture"
    exit 1
    ;;
  esac
  ;;
*)
  echo "Unsupported operating system"
  exit 1
  ;;
esac

CADDY_BINARY=$CADDY_DIR"/"$CADDY_PROCESS_NAME
chmod +x "$CADDY_BINARY"

# Function to start Caddy
start_caddy() {
  if pgrep -f "$CADDY_PROCESS_NAME" >/dev/null; then
    echo "Caddy is already running."
  else
    if [ "$DAEMON" = true ]; then
      nohup "$CADDY_BINARY" run --config=./caddy-file.json 2>&1 >spit.log &
    else
      "$CADDY_BINARY" run --config=./caddy-file.json
    fi
    echo "Caddy started."
  fi
}

# Function to stop Caddy
stop_caddy() {
  if pgrep -f "$CADDY_PROCESS_NAME" >/dev/null; then
    pkill -f "$CADDY_PROCESS_NAME"
    echo "Caddy stopped."
  else
    echo "Caddy is not running."
  fi
}

# Perform the specified action
case "$ACTION" in
start) start_caddy ;;
stop) stop_caddy ;;
daemon)
  DAEMON=true
  start_caddy
  ;;
*) echo "Usage: $0 [start|stop|daemon] [port_number] [upstream_pattern] [upstream_host]" ;;
esac
