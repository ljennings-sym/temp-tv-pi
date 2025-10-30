#!/bin/bash
set -euo pipefail

########################################
# Configuration
########################################

SPLASH="/usr/local/share/videoplayerd/splash.png"   # splash image path
MEDIA_DIR="/media/usb-player"                      # where USBs are mounted
# SPLASH="assets/splash.png"
# MEDIA_DIR="/tmp/usb-test"
POLL_INTERVAL=2                                    # seconds between checks
IPC_SOCKET="/tmp/mpv-socket"                       # mpv IPC socket

########################################
# Helper functions
########################################

# Send command to mpv via IPC socket
mpv_cmd() {
    local cmd="$1"
    if [ -e "$IPC_SOCKET" ]; then
        echo "$cmd" | socat - "$IPC_SOCKET"
    fi
}

# Switch mpv to splash
switch_to_splash() {
    mpv_cmd "{ \"command\": [\"loadfile\", \"$SPLASH\", \"replace\"] }"
}

# Switch mpv to video
switch_to_video() {
    local video="$1"
    mpv_cmd "{ \"command\": [\"loadfile\", \"$video\", \"replace\"] }"
}

########################################
# Initial USB mount check
########################################
# udev only triggers when the usb is plugged in. If a usb drive is plugged in before the pi powers on, then udev wont trigger. 
# This checks if there is a USB storage device detected, and mounts it if found.

# If USB is already plugged in at boot, mount it
if lsblk -o MOUNTPOINT | grep -q "$MEDIA_DIR"; then
    echo "USB already mounted at boot"
else
    if blkid /dev/sda1 >/dev/null 2>&1; then
        echo "USB detected at boot — mounting..."
        mount /dev/sda1 "$MEDIA_DIR" || echo "Mount failed"
    fi
fi





########################################
# Start mpv with splash
########################################

# Make sure previous socket is removed
rm -f "$IPC_SOCKET"

mpv --fs --loop "$SPLASH" --no-terminal --input-ipc-server="$IPC_SOCKET" &
MPV_PID=$!
echo "Started mpv splash (PID $MPV_PID)"

########################################
# Main USB polling loop
########################################

shopt -s nullglob  # so empty glob expands to nothing
VIDEO_PLAYING=""

while true; do
    if mountpoint -q "$MEDIA_DIR"; then
        # Find first MP4 on USB
        videos=("$MEDIA_DIR"/*.mp4)
        if [ -f "${videos[0]}" ] && [ "$VIDEO_PLAYING" != "${videos[0]}" ]; then
            echo "Playing video: ${videos[0]}"
            switch_to_video "${videos[0]}"
            VIDEO_PLAYING="${videos[0]}"
        fi
    else
        # USB not mounted → go back to splash
        if [ -n "$VIDEO_PLAYING" ]; then
            echo "USB removed — switching back to splash"
            switch_to_splash
            VIDEO_PLAYING=""
        fi
    fi
    sleep "$POLL_INTERVAL"
done
