
BRIGHTNESS_STEP=10
NOTIFICATION_TIMEOUT=2000
MIN_BRIGHTNESS=5
MAX_BRIGHTNESS=100

# Get current brightness percentage
get_brightness() {
    if command -v brightnessctl >/dev/null 2>&1; then
        brightnessctl get | awk -v max="$(brightnessctl max)" '{print int($1/max*100)}'
    elif command -v xbacklight >/dev/null 2>&1; then
        xbacklight -get | cut -d. -f1
    else
        echo "Error: Install brightnessctl or xbacklight" >&2
        exit 1
    fi
}

# Increase brightness
brightness_up() {
    local current=$(get_brightness)
    local new_brightness=$((current + BRIGHTNESS_STEP))
    
    if [[ $new_brightness -gt $MAX_BRIGHTNESS ]]; then
        new_brightness=$MAX_BRIGHTNESS
    fi
    
    if command -v brightnessctl >/dev/null 2>&1; then
        brightnessctl set "${new_brightness}%"
    elif command -v xbacklight >/dev/null 2>&1; then
        xbacklight -set $new_brightness
    fi
    show_notification
}

# Decrease brightness
brightness_down() {
    local current=$(get_brightness)
    local new_brightness=$((current - BRIGHTNESS_STEP))
    
    if [[ $new_brightness -lt $MIN_BRIGHTNESS ]]; then
        new_brightness=$MIN_BRIGHTNESS
    fi
    
    if command -v brightnessctl >/dev/null 2>&1; then
        brightnessctl set "${new_brightness}%"
    elif command -v xbacklight >/dev/null 2>&1; then
        xbacklight -set $new_brightness
    fi
    show_notification
}

# Set specific brightness level
set_brightness() {
    local target=$1
    
    if [[ $target -lt $MIN_BRIGHTNESS ]]; then
        target=$MIN_BRIGHTNESS
    elif [[ $target -gt $MAX_BRIGHTNESS ]]; then
        target=$MAX_BRIGHTNESS
    fi
    
    if command -v brightnessctl >/dev/null 2>&1; then
        brightnessctl set "${target}%"
    elif command -v xbacklight >/dev/null 2>&1; then
        xbacklight -set $target
    fi
    show_notification
}

# Show notification
show_notification() {
    local brightness=$(get_brightness)
    
    # Determine icon based on brightness
    local icon
    if [[ $brightness -lt 25 ]]; then
        icon="brightness-low"
    elif [[ $brightness -lt 75 ]]; then
        icon="brightness-medium"
    else
        icon="brightness-high"
    fi
    
    # Create progress bar
    local bar_length=20
    local filled_length=$((brightness * bar_length / 100))
    local bar=""
    
    for ((i=1; i<=bar_length; i++)); do
        if [[ $i -le $filled_length ]]; then
            bar+="█"
        else
            bar+="░"
        fi
    done
    
    # Send notification
    if command -v notify-send >/dev/null 2>&1; then
        notify-send -t $NOTIFICATION_TIMEOUT \
            -h string:x-canonical-private-synchronous:brightness-notification \
            -i "$icon" "Brightness" "$bar $brightness%"
    fi
}

# Main
case "$1" in
    up|+)
        brightness_up
        ;;
    down|-)
        brightness_down
        ;;
    set)
        if [[ -n "$2" && "$2" =~ ^[0-9]+$ ]]; then
            set_brightness "$2"
        else
            echo "Error: Provide brightness level (0-100)" >&2
            exit 1
        fi
        ;;
    get)
        brightness=$(get_brightness)
        echo "Brightness: $brightness%"
        ;;
    *)
        echo "Error: Unknown option: $1" >&2
        exit 1
        ;;
esac
