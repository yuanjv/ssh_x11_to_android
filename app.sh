#!/bin/bash

# Configuration
REMOTE_ADDR='user@ip'
APP_CLASS=''
# Do this if you want run a flatpak app: flatpak run --socket=x11 --share=network [flatpak_id]
APP_RUN_CMD=''
APP_KILL_CMD=''
WINDOW_TITLE_PATTERN=''  # Pattern to identify the APP window
X11_DISPLAY=':0'

# Cleanup function to kill all child processes when the script exits
cleanup() {
    echo "Cleaning up processes..."
    ssh "$REMOTE_ADDR" "$APP_KILL_CMD" || true
    pkill -P $$ || true
}

# Set up cleanup trap
trap cleanup EXIT

# Function to find the main window ID
find_main_window() {
    xdotool search --class "$APP_CLASS" | while read -r id; do
        if xdotool getwindowname "$id" | grep -q "$WINDOW_TITLE_PATTERN"; then
            echo "$id"
            return 0
        fi
    done
    return 1
}

keep_max(){
    # Wait for and locate the main window
    echo "Waiting for main window..."
    while true; do
        sleep 1
        main_window_id=$(find_main_window)

        if [ -n "$main_window_id" ]; then
            echo "Main window found: $main_window_id"
            break
        fi
    done

    # Keep the window maximized
    echo "Maintaining main window size..."
    while true; do
        #echo "Maxing..."
        xdotool windowsize "$main_window_id" 100% 100%
        xdotool windowmove "$main_window_id" 0 0
        sleep 1
    done
}

# Initialize Android X server
echo "Starting X11 server..."
termux-x11 "$X11_DISPLAY" &
export DISPLAY="$X11_DISPLAY"

# Max the main window
keep_max &

# Launch APP via SSH
echo "Launching APP..."
ssh -Y "$REMOTE_ADDR" "$APP_RUN_CMD" &
wait
