#!/bin/bash

# Start Xvfb
Xvfb :99 -screen 0 1920x1080x24 > /dev/null 2>&1 &

# Start dbus
mkdir -p /var/run/dbus
dbus-daemon --system --fork

# Wait for Xvfb
until xdpyinfo -display :99 >/dev/null 2>&1; do
    echo "Waiting for Xvfb..."
    sleep 1
done

# Execute CMD
exec "$@" 