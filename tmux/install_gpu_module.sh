#!/bin/bash

# Catppuccin GPU Module Installer
# Adds beautiful GPU monitoring to tmux status bar

set -e

echo "🖥️  Installing GPU module for Catppuccin tmux theme..."

# Check if Catppuccin tmux is installed
CATPPUCCIN_PATH="$HOME/.tmux/plugins/tmux/catppuccin"
if [ ! -d "$CATPPUCCIN_PATH" ]; then
    echo "❌ Catppuccin tmux theme not found. Please install it first:"
    echo "   https://github.com/catppuccin/tmux"
    exit 1
fi

# Install gpuinfo if not already installed
if ! command -v gpuinfo >/dev/null 2>&1; then
    echo "📦 Installing gpuinfo..."
    sudo make install
else
    echo "✅ gpuinfo already installed"
fi

# Copy GPU module to Catppuccin directory
echo "📁 Installing GPU module..."
sudo cp catppuccin_gpu.conf "$CATPPUCCIN_PATH/status/gpu.conf"

# Update tmux config
echo "⚙️  Updating tmux configuration..."
if grep -q "catppuccin_status_gpu" ~/.tmux.conf; then
    echo "✅ GPU module already configured in tmux.conf"
else
    # Remove our simple GPU line if it exists
    sed -i '' '/tmux-gpu.tmux/d' ~/.tmux.conf
    
    # Add proper Catppuccin GPU module
    sed -i '' '/set -agF status-right "#{E:@catppuccin_status_cpu}"/a\
set -agF status-right "#{E:@catppuccin_status_gpu}"
' ~/.tmux.conf
    echo "✅ Added GPU module to tmux.conf"
fi

echo ""
echo "🎉 Installation complete!"
echo ""
echo "To activate:"
echo "1. Reload tmux config: tmux source-file ~/.tmux.conf"
echo "2. Or press Ctrl+s then 'r' (your reload binding)"
echo ""
echo "The GPU module will show:"
echo "• 📘 Blue background: Low usage (0-25%)"
echo "• 🟨 Yellow background: Medium usage (25-50%)"
echo "• 🟧 Orange background: High usage (50-80%)"
echo "• 🟥 Red background: Critical usage (80%+)"