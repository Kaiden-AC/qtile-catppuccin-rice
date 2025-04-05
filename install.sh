#!/bin/bash

# --- qtile-catppuccin-rice Installation Script ---
# Based on user request for Arch Linux

# Exit immediately if a command exits with a non-zero status.
set -e

# --- Variables ---
REPO_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )" # Gets the directory where the script is located
CONFIG_DIR="$HOME/.config"
WALLPAPER_SRC="$REPO_DIR/wallpaper/catppuccin_wallpaper.jpg"
WALLPAPER_DEST="$CONFIG_DIR/qtile/wallpaper.jpg" # Destination expected by autostart.sh

# --- Functions ---
print_info() {
    echo -e "\e[34m[INFO]\e[0m $1"
}

print_success() {
    echo -e "\e[32m[SUCCESS]\e[0m $1"
}

print_warning() {
    echo -e "\e[33m[WARNING]\e[0m $1"
}

print_error() {
    echo -e "\e[31m[ERROR]\e[0m $1" >&2
}

# --- Ensure running as non-root, but check for sudo ---
if [ "$(id -u)" -eq 0 ]; then
   print_error "This script should not be run as root. Run it as your regular user. It will prompt for sudo when needed."
   exit 1
fi

# Refresh sudo timestamp
sudo -v
print_info "Checked for sudo privileges."

# --- Confirmation ---
echo "-----------------------------------------------------"
echo " Qtile Catppuccin Rice Installer for Arch Linux"
echo "-----------------------------------------------------"
print_warning "This script will:"
echo "  - Update your system via pacman."
echo "  - Install necessary packages (Qtile, Xorg, helpers, themes)."
echo "  - !! OVERWRITE existing configurations !! in:"
echo "      - $CONFIG_DIR/qtile"
echo "      - $CONFIG_DIR/alacritty"
echo "      - $CONFIG_DIR/rofi"
echo "      - $CONFIG_DIR/picom"
echo "      - $CONFIG_DIR/dunst"
echo "  - Copy wallpaper."
echo "  - Set GTK/Icon themes (requires manual setup via lxappearance later or included files)."
echo
read -p "Do you want to proceed? (y/N): " confirm
if [[ "$confirm" != [yY] && "$confirm" != [yY][eE][sS] ]]; then
    echo "Installation aborted."
    exit 0
fi

# --- Update System ---
print_info "Updating system packages..."
sudo pacman -Syu --noconfirm || { print_error "Failed to update system."; exit 1; }
print_success "System updated."

# --- Install Dependencies ---
print_info "Installing core dependencies..."
CORE_DEPS=(
    xorg-server xorg-xinit xorg-xrandr xorg-xsetroot # Xorg basics
    qtile python-psutil python-dbus-next python-iwlib # Qtile and its deps
    alacritty # Terminal
    rofi # Launcher
    feh # Wallpaper setter
    picom # Compositor
    dunst # Notifications
    ttf-jetbrains-mono-nerd # Nerd Font for icons
    lxappearance # GTK Theming helper
    papirus-icon-theme # Base Icon Theme
    pamixer # Volume control command-line tool
    brightnessctl # Brightness control command-line tool
    git # Needed for papirus-folders if cloning
)

sudo pacman -S --needed --noconfirm "${CORE_DEPS[@]}" || { print_error "Failed to install core dependencies."; exit 1; }
print_success "Core dependencies installed."

# --- Install Catppuccin GTK Theme & Papirus Folders (More Automated Approach) ---
print_info "Setting up Catppuccin GTK theme and Papirus folders..."
TEMP_DIR=$(mktemp -d)
trap 'rm -rf -- "$TEMP_DIR"' EXIT # Clean up temp directory on exit

# Clone GTK theme
print_info "Cloning Catppuccin GTK theme..."
git clone --depth 1 https://github.com/catppuccin/gtk.git "$TEMP_DIR/gtk" || { print_warning "Failed to clone GTK theme."; }
if [ -d "$TEMP_DIR/gtk/src" ]; then
    print_info "Installing GTK themes system-wide..."
    sudo cp -r "$TEMP_DIR/gtk/src/"* /usr/share/themes/ || print_warning "Failed to copy GTK themes."
    print_success "Catppuccin GTK themes installed to /usr/share/themes/."
else
    print_warning "Catppuccin GTK theme directory structure not found as expected."
fi

# Clone and setup Papirus Folders
print_info "Cloning Catppuccin Papirus Folders..."
git clone --depth 1 https://github.com/catppuccin/papirus-folders.git "$TEMP_DIR/papirus-folders" || { print_warning "Failed to clone Papirus Folders."; }
if [ -f "$TEMP_DIR/papirus-folders/papirus-folders" ]; then
    print_info "Copying Papirus Folder scripts and applying Catppuccin variant (Mauve)..."
    sudo cp -r "$TEMP_DIR/papirus-folders/src/"* /usr/share/icons/ # Copy base color folders
    sudo cp "$TEMP_DIR/papirus-folders/papirus-folders" /usr/bin/
    sudo chmod +x /usr/bin/papirus-folders
    sudo papirus-folders -C cat-mauve --theme Papirus-Dark || print_warning "Failed to set Papirus folder color. Manual run might be needed."
    print_success "Papirus Folders script installed and Catppuccin Mauve variant applied for Papirus-Dark."
    print_info "You may need to re-run 'sudo papirus-folders -C <color> --theme <Papirus-Theme>' if you change the base Papirus theme later."
else
    print_warning "Papirus Folders script not found as expected."
fi

# --- Create Necessary Directories ---
print_info "Creating configuration directories..."
mkdir -p "$CONFIG_DIR/qtile"
mkdir -p "$CONFIG_DIR/alacritty"
mkdir -p "$CONFIG_DIR/rofi"
mkdir -p "$CONFIG_DIR/picom"
mkdir -p "$CONFIG_DIR/dunst"
mkdir -p "$HOME/.local/share/fonts" # For user fonts if needed later
print_success "Configuration directories ensured."

# --- Copy Configuration Files ---
print_info "Copying configuration files from repository..."
# Use rsync for potentially better handling and verbose output (optional)
# rsync -av --no-perms --exclude='.git' "$REPO_DIR/.config/" "$CONFIG_DIR/" # More robust copy
cp -r "$REPO_DIR/.config/qtile/"* "$CONFIG_DIR/qtile/" || print_warning "Failed to copy Qtile configs."
cp -r "$REPO_DIR/.config/alacritty/"* "$CONFIG_DIR/alacritty/" || print_warning "Failed to copy Alacritty config."
cp -r "$REPO_DIR/.config/rofi/"* "$CONFIG_DIR/rofi/" || print_warning "Failed to copy Rofi configs."
cp -r "$REPO_DIR/.config/picom/"* "$CONFIG_DIR/picom/" || print_warning "Failed to copy Picom config."
cp -r "$REPO_DIR/.config/dunst/"* "$CONFIG_DIR/dunst/" || print_warning "Failed to copy Dunst config."

# --- Copy Wallpaper ---
if [ -f "$WALLPAPER_SRC" ]; then
    print_info "Copying wallpaper..."
    cp "$WALLPAPER_SRC" "$WALLPAPER_DEST" || print_warning "Failed to copy wallpaper."
    print_success "Wallpaper copied to $WALLPAPER_DEST."
else
    print_warning "Wallpaper source file not found at $WALLPAPER_SRC."
fi

# --- Make Autostart Script Executable ---
print_info "Making autostart script executable..."
chmod +x "$CONFIG_DIR/qtile/autostart.sh" || print_warning "Failed to make autostart script executable."
print_success "Autostart script is now executable."

# --- Set GTK Theme (using included files as fallback/alternative) ---
# This part assumes you might want pre-configured GTK setting files.
# If you prefer using lxappearance manually, comment this section out.
# print_info "Attempting to set GTK themes via config files (if present in repo)..."
# if [ -f "$REPO_DIR/assets/gtkrc-2.0" ]; then
#     cp "$REPO_DIR/assets/gtkrc-2.0" "$HOME/.gtkrc-2.0" || print_warning "Failed to copy .gtkrc-2.0"
#     print_success "Copied GTK2 settings."
# fi
# if [ -f "$REPO_DIR/assets/settings.ini" ]; then
#     mkdir -p "$CONFIG_DIR/gtk-3.0"
#     cp "$REPO_DIR/assets/settings.ini" "$CONFIG_DIR/gtk-3.0/settings.ini" || print_warning "Failed to copy gtk-3.0/settings.ini"
#     print_success "Copied GTK3 settings."
# fi
# print_info "Note: For GTK themes to apply reliably, use lxappearance after install or ensure included files are correct."

# --- Final Instructions ---
echo
print_success "Installation script finished!"
echo "-----------------------------------------------------"
print_info "Next Steps:"
echo "1.  Log out of your current session."
echo "2.  If using a display manager (like LightDM, SDDM): Select 'Qtile' from the session menu before logging in."
echo "3.  If starting from TTY: Type 'startx' (ensure ~/.xinitrc contains 'exec qtile start')."
echo "      You might need to create/edit ~/.xinitrc:"
echo "      echo 'exec qtile start' > ~/.xinitrc"
echo "      chmod +x ~/.xinitrc"
echo "4.  Run 'lxappearance' after logging into Qtile to verify/select:"
echo "      - Widget Theme: Catppuccin-Mocha-... (or your preferred variant)"
echo "      - Icon Theme: Papirus-Dark (or Papirus/Papirus-Light)"
echo "5.  Enjoy your Catppuccin Qtile Rice!"
echo "6.  Troubleshooting: Check ~/.local/share/qtile/qtile.log for errors."
echo "-----------------------------------------------------"

exit 0
