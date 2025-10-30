#!/bin/bash

# working directory is /usr/local/share/videoplayerd (set in systemd)
SPLASH="splash.png"
MEDIA_DIR="/media/usb-player"

# Show splash screen first
mpv --fs --loop "$SPLASH" &

SPLASH_PID=$!

# Wait for USB device to appear
while true; do
    if mount | grep -q "$MEDIA_DIR"; then
        # Kill splash screen
        kill $SPLASH_PID 2>/dev/null || true

        # Play any mp4 files on the USB
        for f in "$MEDIA_DIR"/*.mp4; do
            [ -e "$f" ] || continue
            mpv --fs "$f"
        done

        # Restart splash if USB is removed
        mpv --fs --loop "$SPLASH" &
        SPLASH_PID=$!
    fi
    sleep 2
done
