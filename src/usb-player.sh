#!/bin/bash
# usb-video-player.sh
# Continuously watches for USB drives, plays .mp4 files on them,
# and shows a fallback image when no video is playing.

MOUNT_BASE="/media/$USER"    # adjust if your system auto-mounts elsewhere
CHECK_INTERVAL=5             # seconds between checks
# FALLBACK_IMAGE="$HOME/Pictures/fallback.png"  # change to your image path
FALLBACK_IMAGE="$HOME/.config/usb-video-player/splash.png"

VLC_PID=""
IMV_PID=""

stop_imv() {
    [ -n "$IMV_PID" ] && kill "$IMV_PID" 2>/dev/null
    IMV_PID=""
}

play_videos() {
    local mountpoint="$1"
    local videos=("$mountpoint"/*.mp4)

    if [ -f "${videos[0]}" ]; then
        echo "Playing videos from $mountpoint..."
        # Stop fallback image if running
        # stop_imv

        vlc --fullscreen --loop --no-video-title-show --no-osd \
            --no-qt-fs-controller --no-mouse-events \
            --quiet "${videos[0]}" &
        VLC_PID=$!

        # While the USB is still mounted, keep VLC running
        while mountpoint -q "$mountpoint"; do
            sleep 1
        done

        echo "Drive removed — stopping playback..."
        kill $VLC_PID 2>/dev/null
        wait $VLC_PID 2>/dev/null
        VLC_PID=""
    fi
}

show_fallback() {
    # Only start imv if it's not already running
    if [ -z "$IMV_PID" ]; then
        echo "Displaying fallback image..."
        imv-wayland -f "$FALLBACK_IMAGE" &
        IMV_PID=$!
    fi
}


while true; do
    USB_FOUND=false
    for dir in "$MOUNT_BASE"/*; do
        [ -d "$dir" ] || continue
        if find "$dir" -maxdepth 1 -type f -name '*.mp4' | grep -q .; then
            USB_FOUND=true
            # Stop any existing VLC before playing new drive
            pkill vlc 2>/dev/null
            play_videos "$dir"
        fi
    done

    # # Show fallback image if no USB video is found
    # if [ "$USB_FOUND" = false ]; then
    #     show_fallback
    # else
    #     # Stop fallback if a USB video appeared
    #     stop_imv
    # fi
    # Turns out that you can just show the fallback screen consistently, which also takes care of the mouse.
    show_fallback

    sleep $CHECK_INTERVAL
done
