#!/usr/bin/env bash

# Catppuccin-styled GPU plugin for tmux
# Uses gpuinfo to display GPU utilization with beautiful colors

get_gpu_usage() {
    if command -v gpuinfo >/dev/null 2>&1; then
        local gpu_usage=$(gpuinfo -p 2>/dev/null || echo "0")
        if [[ "$gpu_usage" =~ ^[0-9]+$ ]]; then
            echo "$gpu_usage"
        else
            echo "0"
        fi
    else
        echo "0"
    fi
}

get_gpu_format() {
    local gpu_usage=$(get_gpu_usage)
    local icon="󰢮"
    
    # Catppuccin Mocha colors
    local bg_low="#313244"      # surface0 
    local bg_medium="#f9e2af"   # yellow
    local bg_high="#fab387"     # peach
    local bg_critical="#f38ba8" # red
    
    local fg_low="#cdd6f4"      # text
    local fg_medium="#1e1e2e"   # crust
    local fg_high="#1e1e2e"     # crust
    local fg_critical="#1e1e2e" # crust
    
    # Determine colors based on usage
    if [ "$gpu_usage" -lt 25 ]; then
        local bg_color="$bg_low"
        local fg_color="$fg_low"
    elif [ "$gpu_usage" -lt 50 ]; then
        local bg_color="$bg_medium" 
        local fg_color="$fg_medium"
    elif [ "$gpu_usage" -lt 80 ]; then
        local bg_color="$bg_high"
        local fg_color="$fg_high"
    else
        local bg_color="$bg_critical"
        local fg_color="$fg_critical"
    fi
    
    # Format with left separator, content, and right separator
    local left_sep=""
    local right_sep=""
    
    # Previous module background (CPU uses surface0)
    local prev_bg="#313244"
    
    echo "#[fg=${bg_color},bg=${prev_bg}]${left_sep}#[fg=${fg_color},bg=${bg_color}] ${icon} ${gpu_usage}% #[fg=${bg_color}]${right_sep}"
}

# Main execution
case "$1" in
    "usage")
        get_gpu_usage
        ;;
    "format"|*)
        get_gpu_format
        ;;
esac