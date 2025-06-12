
WALLPAPER_DIR="$HOME/Pictures/wallpapers"

# Create directory if it doesn't exist
mkdir -p "$WALLPAPER_DIR"

# Function to set wallpaper
set_wallpaper() {
    local wallpaper="$1"
    if [[ -f "$wallpaper" ]]; then
        # Preload the image
        hyprctl hyprpaper preload "$wallpaper"
        
        # Apply to all available monitors
        local monitors=$(hyprctl monitors -j | jq -r '.[].name')
        for monitor in $monitors; do
            hyprctl hyprpaper wallpaper "$monitor,$wallpaper"
        done
        
        # Alternative method without jq
        if [[ -z "$monitors" ]]; then
            hyprctl monitors | grep "Monitor" | awk '{print $2}' | while read -r monitor; do
                hyprctl hyprpaper wallpaper "$monitor,$wallpaper"
            done
        fi
        
        echo "Wallpaper set: $wallpaper"
    else
        echo "Error: File does not exist: $wallpaper"
        exit 1
    fi
}

# Function for interactive selector
select_wallpaper() {
    if command -v rofi >/dev/null 2>&1; then
        local selected=$(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) | rofi -dmenu -i -p "Select wallpaper:")
    elif command -v fzf >/dev/null 2>&1; then
        local selected=$(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) | fzf --preview 'echo {} && file {}' --prompt "Wallpaper: ")
    else
        echo "Error: Install rofi or fzf for interactive selector"
        exit 1
    fi
    
    if [[ -n "$selected" ]]; then
        set_wallpaper "$selected"
    else
        echo "No wallpaper selected"
    fi
}

# Main
if [[ -n "$1" ]]; then
    if [[ -f "$1" ]]; then
        set_wallpaper "$1"
    else
        echo "Error: File not found: $1"
        exit 1
    fi
else
    select_wallpaper
fi