#!/bin/bash
set -euo pipefail
shopt -s nullglob  # so empty glob expands to nothing

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


# Helper function to get all videos from MEDIA_DIR
get_videos() {
    local -n arr_ref=$1
    mapfile -t arr_ref < <(ls "$MEDIA_DIR"/*.mp4 2>/dev/null)
}

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
# Start keyboard listener so we can quit mpv
########################################
# Trap SIGTERM so the script can quit mpv cleanly
trap 'echo "Stopping..."; mpv_cmd "{ \"command\": [\"quit\"] }"; exit 0' SIGTERM

# Background key listener
kbd_listener() {
    while true; do
        # read a single key without echo, from the current tty
        read -rsn1 key
        if [[ $key == "q" ]]; then
            echo "Keyboard quit pressed"
            kill -TERM "$$"
            break
        fi
    done
}

kbd_listener &


########################################
# Initial USB mount check
########################################
# udev only triggers when the usb is plugged in. If a usb drive is plugged in before the pi powers on, then udev wont trigger. 
# This checks if there is a USB storage device detected, and mounts it if found.


USB_DEV=$(
  lsblk -rno NAME,TYPE,TRAN | awk '$2=="disk" && $3=="usb" {print "/dev/"$1; exit}'
)


# need to check if the usb device has any partitions, or if it should just be mounted as a raw disk
if [ -n "$USB_DEV" ]; then
    # Determine what to mount
    if lsblk "$USB_DEV" -no NAME,TYPE | grep -q "part"; then
        # has partitions, mount first one
        USB_PART=$(lsblk -rno NAME,TYPE "$USB_DEV" | awk '$2=="part"{print "/dev/"$1; exit}')
        MOUNT_TARGET="$USB_PART"
    else
        # no partitions, mount disk directly
        MOUNT_TARGET="$USB_DEV"
    fi

    # mount if not mounted
    if ! mountpoint -q "$MEDIA_DIR"; then
        mount "$MOUNT_TARGET" "$MEDIA_DIR"
    fi
fi


INITIAL_VIDEO=$SPLASH
VIDEO_PLAYING=""

# STARTUP_VIDEOS=
get_videos STARTUP_VIDEOS


if [ -f "${STARTUP_VIDEOS[0]}" ]; then
    INITIAL_VIDEO="${STARTUP_VIDEOS[0]}"
    VIDEO_PLAYING="${STARTUP_VIDEOS[0]}"
fi



########################################
# Start mpv with splash
########################################

# Make sure previous socket is removed
rm -f "$IPC_SOCKET"

mpv --fs "$INITIAL_VIDEO" --no-terminal --input-ipc-server="$IPC_SOCKET" &
MPV_PID=$!
echo "Started mpv splash (PID $MPV_PID)"
sleep 1


########################################
# Main USB polling loop
########################################


while true; do
    if mountpoint -q "$MEDIA_DIR"; then
        # Find first MP4 on USB
        get_videos videos
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
