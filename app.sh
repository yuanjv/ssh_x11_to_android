#!/bin/bash

# Configuration
REMOTE_ADDR='user@ip'
APP_CLASS=''
#do this if you want run a flatpak app: flatpak run --socket=x11 --share=network [flatpak_id]
APP_RUN_CMD=''
WINDOW_TITLE_PATTERN=''  # Pattern to identify the APP window
X11_DISPLAY=':0'

# Cleanup function to kill all child processes when the script exits
cleanup() {
    echo "Cleaning up processes..."
    pkill -P $$
}

# Set up cleanup trap
trap cleanup EXIT

# Function to find the main window ID
find_main_window() {
    xdotool search --class "$APP_CLASS" | while read -r id; do
        if xdotool getwindowname "$id" 2>/dev/null | grep -q "$WINDOW_TITLE_PATTERN"; then
            echo "$id"
            return 0
        fi
    done
    return 1
}

# Initialize Android X server
echo "Starting X11 server..."
termux-x11 "$X11_DISPLAY" &
export DISPLAY="$X11_DISPLAY"

# Launch APP via SSH
echo "Launching APP..."
ssh -Y "$REMOTE_ADDR" "$APP_RUN_CMD" &

# Wait for and locate the main window
echo "Waiting for main window..."
while true; do
    main_window_id=$(find_main_window)

    if [ -n "$main_window_id" ]; then
        echo "Main window found: $main_window_id"
        break
    fi

    sleep 1
done

# Keep the window maximized
echo "Maintaining main window size..."
while true; do
    if ! xdotool windowsize "$main_window_id" 100% 100% && \
       xdotool windowmove "$main_window_id" 0 0; then
        echo "Warning: Failed to resize window, retrying..."
    fi
    sleep 1
done

wait
