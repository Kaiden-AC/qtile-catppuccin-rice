#!/bin/bash

# Autostart script for Qtile

# Set wallpaper
feh --bg-fill ~/.config/qtile/catppuccin_triangle.png & # Change path to your wallpaper

# Start compositor (picom)
picom --config ~/.config/picom/picom.conf &

# Start notification daemon (dunst)
dunst &

# Start network manager applet (if you use NetworkManager)
# nm-applet &

# Start volume icon (if needed and not handled by bar widget)
# volumeicon &

# Start clipboard manager (e.g., copyq, clipmenu) - Install one first!
# copyq &

# Other startup applications:
# discord &
# steam &
