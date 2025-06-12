#!/bin/bash

# Rofi WiFi Menu Script
# Dependencias: NetworkManager, rofi

# Colores
export ROFI_THEME="~/.config/rofi/themes/catppuccin.rasi"

# Función para mostrar redes disponibles
show_networks() {
    # Escanear redes disponibles
    nmcli device wifi rescan 2>/dev/null
    sleep 2
    
    # Obtener lista de redes
    networks=$(nmcli -t -f SSID,SECURITY,SIGNAL device wifi list | \
               awk -F: '!seen[$1]++ && $1 != "" {
                   if($2 == "") security="󰖩 "; 
                   else security="󰒃 ";
                   printf "%s%s\n", security, $1
               }' | head -20)
    
    # Opciones adicionales
    options="󰤨 Scan Networks\n󰤭 Disconnect\n󰒃 Manual Connection\n$networks"
    
    # Mostrar menú
    selected=$(echo -e "$options" | rofi -dmenu -i -p "WiFi Networks" \
               -theme "$ROFI_THEME" \
               -lines 15 \
               -width 400)
    
    case "$selected" in
        "󰤨 Scan Networks")
            show_networks
            ;;
        "󰤭 Disconnect")
            disconnect_wifi
            ;;
        "󰒃 Manual Connection")
            manual_connection
            ;;
        *)
            if [[ -n "$selected" ]]; then
                # Extraer el nombre de la red (quitar el icono)
                ssid=$(echo "$selected" | sed 's/^[󰖩󰒃] //')
                connect_to_network "$ssid"
            fi
            ;;
    esac
}

# Función para conectar a una red
connect_to_network() {
    local ssid="$1"
    
    # Verificar si la red está guardada
    if nmcli connection show | grep -q "$ssid"; then
        # Conectar a red guardada
        if nmcli connection up "$ssid" 2>/dev/null; then
            notify-send "WiFi" "Connected to $ssid" -i network-wireless
        else
            notify-send "WiFi" "Failed to connect to $ssid" -i network-wireless-disconnected
        fi
    else
        # Red nueva, pedir contraseña
        password=$(rofi -dmenu -password -p "Password for $ssid" \
                   -theme "$ROFI_THEME" \
                   -lines 1)
        
        if [[ -n "$password" ]]; then
            if nmcli device wifi connect "$ssid" password "$password" 2>/dev/null; then
                notify-send "WiFi" "Connected to $ssid" -i network-wireless
            else
                notify-send "WiFi" "Failed to connect to $ssid" -i network-wireless-disconnected
            fi
        fi
    fi
}

# Función para desconectar WiFi
disconnect_wifi() {
    current_ssid=$(nmcli -t -f active,ssid dev wifi | awk -F: '$1=="yes" {print $2}')
    
    if [[ -n "$current_ssid" ]]; then
        nmcli connection down "$current_ssid"
        notify-send "WiFi" "Disconnected from $current_ssid" -i network-wireless-disconnected
    else
        notify-send "WiFi" "No active connection" -i network-wireless-offline
    fi
}

# Función para conexión manual
manual_connection() {
    ssid=$(rofi -dmenu -p "Enter SSID" \
            -theme "$ROFI_THEME" \
            -lines 1)
    
    if [[ -n "$ssid" ]]; then
        connect_to_network "$ssid"
    fi
}

# Verificar dependencias
if ! command -v nmcli &> /dev/null; then
    notify-send "Error" "NetworkManager not found" -i dialog-error
    exit 1
fi

if ! command -v rofi &> /dev/null; then
    notify-send "Error" "Rofi not found" -i dialog-error
    exit 1
fi

# Iniciar menú
show_networks
