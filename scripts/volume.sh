
VOLUME_STEP=5
NOTIFICATION_TIMEOUT=2000

# Get current volume
get_volume() {
    if command -v pamixer >/dev/null 2>&1; then
        pamixer --get-volume
    elif command -v pactl >/dev/null 2>&1; then
        pactl get-sink-volume @DEFAULT_SINK@ | grep -Po '\d+(?=%)' | head -1
    else
        echo "Error: Install pamixer or pulseaudio-utils" >&2
        exit 1
    fi
}

# Check if muted
is_muted() {
    if command -v pactl >/dev/null 2>&1; then
        pactl get-sink-mute @DEFAULT_SINK@ | grep -q "yes"
    elif command -v pamixer >/dev/null 2>&1; then
        pamixer --get-mute
    fi
}

# Increase volume
volume_up() {
    if command -v pamixer >/dev/null 2>&1; then
        pamixer -i $VOLUME_STEP --allow-boost
    elif command -v pactl >/dev/null 2>&1; then
        pactl set-sink-volume @DEFAULT_SINK@ +${VOLUME_STEP}%
    fi
    show_notification
}

# Decrease volume
volume_down() {
    if command -v pamixer >/dev/null 2>&1; then
        pamixer -d $VOLUME_STEP
    elif command -v pactl >/dev/null 2>&1; then
        pactl set-sink-volume @DEFAULT_SINK@ -${VOLUME_STEP}%
    fi
    show_notification
}

# Toggle mute
toggle_mute() {
    if command -v pactl >/dev/null 2>&1; then
        pactl set-sink-mute @DEFAULT_SINK@ toggle
    elif command -v pamixer >/dev/null 2>&1; then
        pamixer --toggle-mute
    fi
    show_notification
}

# Show notification
show_notification() {
    local volume=$(get_volume)
    local muted=""
    
    if is_muted; then
        muted=" (Muted)"
        volume=0
    fi
    
    # Determine icon based on volume
    local icon
    if [[ $volume -eq 0 ]] || is_muted; then
        icon="audio-volume-muted"
    elif [[ $volume -lt 30 ]]; then
        icon="audio-volume-low"
    elif [[ $volume -lt 70 ]]; then
        icon="audio-volume-medium"
    else
        icon="audio-volume-high"
    fi
    
    # Create progress bar
    local bar_length=20
    local filled_length=$((volume * bar_length / 100))
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
            -h string:x-canonical-private-synchronous:volume-notification \
            -i "$icon" "Volume" "$bar $volume%$muted"
    fi
}

# Main
case "$1" in
    up|+)
        volume_up
        ;;
    down|-)
        volume_down
        ;;
    mute|toggle)
        toggle_mute
        ;;
    get)
        volume=$(get_volume)
        if is_muted; then
            echo "Volume: $volume% (Muted)"
        else
            echo "Volume: $volume%"
        fi
        ;;
    *)
        echo "Error: Unknown option: $1" >&2
        exit 1
        ;;
esac