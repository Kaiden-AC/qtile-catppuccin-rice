#!/bin/bash

# --- qtile-catppuccin-rice Installation Script ---
# Based on user request for Arch Linux - v1.2 (Updated GTK path)

# Exit immediately if a command exits with a non-zero status.
set -e

# --- Variables ---
REPO_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )" # Gets the directory where the script is located
CONFIG_SOURCE_DIR="$REPO_DIR/.config"
CONFIG_DEST_DIR="$HOME/.config"
WALLPAPER_SRC="$REPO_DIR/wallpaper/catppuccin_wallpaper.jpg"
WALLPAPER_DEST="$CONFIG_DEST_DIR/qtile/wallpaper.jpg" # Destination expected by autostart.sh

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
sudo -v || { print_error "Sudo privileges validation failed."; exit 1; }
print_info "Checked for sudo privileges."

# --- Confirmation ---
echo "-----------------------------------------------------"
echo " Qtile Catppuccin Rice Installer for Arch Linux"
echo "-----------------------------------------------------"
print_warning "This script will:"
echo "  - Update your system via pacman."
echo "  - Install necessary packages (Qtile, Xorg, helpers, themes)."
echo "  - !! OVERWRITE existing configurations !! in:"
echo "      - $CONFIG_DEST_DIR/qtile"
echo "      - $CONFIG_DEST_DIR/alacritty"
echo "      - $CONFIG_DEST_DIR/rofi"
echo "      - $CONFIG_DEST_DIR/picom"
echo "      - $CONFIG_DEST_DIR/dunst"
echo "  - Copy wallpaper."
echo "  - Attempt to set GTK/Icon themes system-wide."
echo
# Ensure wallpaper source exists before confirming
if [ ! -f "$WALLPAPER_SRC" ]; then
    print_warning "Wallpaper source file not found at '$WALLPAPER_SRC'. Wallpaper setup will likely fail."
fi
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
    git # Needed for cloning themes
)

sudo pacman -S --needed --noconfirm "${CORE_DEPS[@]}" || { print_error "Failed to install core dependencies."; exit 1; }
print_success "Core dependencies installed."

# --- Install Catppuccin GTK Theme & Papirus Folders (More Automated Approach) ---
print_info "Setting up Catppuccin GTK theme and Papirus folders..."
TEMP_DIR=$(mktemp -d)
# Ensure cleanup happens even if script exits prematurely
trap 'print_info "Cleaning up temporary directory..."; rm -rf -- "$TEMP_DIR"' EXIT

# Clone GTK theme
print_info "Cloning Catppuccin GTK theme..."
if git clone --depth 1 https://github.com/catppuccin/gtk.git "$TEMP_DIR/gtk"; then
    # --- MODIFIED HERE: Check for 'sources' directory ---
    if [ -d "$TEMP_DIR/gtk/sources" ] && [ "$(ls -A "$TEMP_DIR/gtk/sources")" ]; then
        print_info "Installing GTK themes system-wide from sources/..."
        # --- MODIFIED HERE: Copy from 'sources' ---
        sudo cp -r "$TEMP_DIR/gtk/sources/"* /usr/share/themes/ || print_warning "Failed to copy GTK themes from sources/."
        print_success "Catppuccin GTK themes installed to /usr/share/themes/."
    # --- Keep Fallback (just in case, but less likely now) ---
    elif [ "$(ls -A "$TEMP_DIR/gtk" | grep -iE 'Catppuccin-.*')" ]; then
         print_info "Installing GTK themes system-wide from repo root (fallback)..."
         sudo cp -r "$TEMP_DIR/gtk/"* /usr/share/themes/ || print_warning "Failed to copy GTK themes from repo root."
         print_success "Catppuccin GTK themes installed to /usr/share/themes/ (using repo root)."
    else
        print_warning "Could not find expected theme directories in 'sources/' or repo root in the cloned Catppuccin GTK repository. Manual installation might be needed."
    fi
else
    print_warning "Failed to clone Catppuccin GTK theme repository."
fi


# Clone and setup Papirus Folders
print_info "Cloning Catppuccin Papirus Folders..."
if git clone --depth 1 https://github.com/catppuccin/papirus-folders.git "$TEMP_DIR/papirus-folders"; then
    # --- ADDED: Explicit check for the script file ---
    if [ ! -f "$TEMP_DIR/papirus-folders/papirus-folders" ]; then
        print_warning "Main 'papirus-folders' script not found in the cloned repository root. Cannot proceed with Papirus setup."
    else
        print_info "Copying Papirus Folder scripts and applying Catppuccin variant (Mauve)..."
        # Copy base color folders first (important!)
        if [ -d "$TEMP_DIR/papirus-folders/src" ] && [ "$(ls -A "$TEMP_DIR/papirus-folders/src")" ]; then
             sudo cp -r "$TEMP_DIR/papirus-folders/src/"* /usr/share/icons/ || print_warning "Failed to copy Papirus base color folders from src/."
        else
             print_warning "Could not find src/ directory with color folders in Papirus Folders repo."
        fi
        # Copy the script itself
        if sudo cp "$TEMP_DIR/papirus-folders/papirus-folders" /usr/bin/; then
            sudo chmod +x /usr/bin/papirus-folders
            # Attempt to apply the theme color
            if sudo papirus-folders -C cat-mauve --theme Papirus-Dark; then
                print_success "Papirus Folders script installed and Catppuccin Mauve variant applied for Papirus-Dark."
                print_info "You may need to re-run 'sudo papirus-folders -C <color> --theme <Papirus-Theme>' if you change the base Papirus theme."
            else
                print_warning "Command 'papirus-folders -C cat-mauve --theme Papirus-Dark' failed. You might need to run it manually after ensuring Papirus-Dark icons are installed correctly."
            fi
        else
            print_warning "Failed to copy papirus-folders script to /usr/bin."
        fi
    fi # End check for script file existence
else
    print_warning "Failed to clone Catppuccin Papirus Folders repository."
fi


# --- Create Necessary Directories ---
print_info "Creating configuration directories..."
mkdir -p "$CONFIG_DEST_DIR/qtile"
mkdir -p "$CONFIG_DEST_DIR/alacritty"
mkdir -p "$CONFIG_DEST_DIR/rofi"
mkdir -p "$CONFIG_DEST_DIR/picom"
mkdir -p "$CONFIG_DEST_DIR/dunst"
mkdir -p "$HOME/.local/share/fonts" # For user fonts if needed later
print_success "Configuration directories ensured."

# --- Copy Configuration Files ---
print_info "Copying configuration files from repository..."

# Define config mappings: source subdir -> destination subdir
declare -A CONFIG_MAP
CONFIG_MAP=(
    ["qtile"]="$CONFIG_DEST_DIR/qtile"
    ["alacritty"]="$CONFIG_DEST_DIR/alacritty"
    ["rofi"]="$CONFIG_DEST_DIR/rofi"
    ["picom"]="$CONFIG_DEST_DIR/picom"
    ["dunst"]="$CONFIG_DEST_DIR/dunst"
)

COPIED_ANY=false
FAILED_ANY=false
for app in "${!CONFIG_MAP[@]}"; do
    src_path="$CONFIG_SOURCE_DIR/$app"
    dest_path="${CONFIG_MAP[$app]}"
    if [ -d "$src_path" ]; then
        print_info "Copying $app configs..."
        # Copy contents, preserving structure; handle potential errors per app
        if cp -r "$src_path/." "$dest_path/"; then # Use /.* or /.?* if hidden files needed, /./ copies contents
             print_success " -> Copied $app configs to $dest_path"
             COPIED_ANY=true
        else
             print_warning " -> Failed to copy $app configs from $src_path to $dest_path."
             FAILED_ANY=true
        fi
    else
        print_warning " -> Source config directory not found: $src_path"
        FAILED_ANY=true
    fi
done

if ! $COPIED_ANY && $FAILED_ANY; then
    print_error "Failed to copy any configuration files. Please check the repository structure."
elif $FAILED_ANY; then
    print_warning "Some configuration files failed to copy. Please review the warnings above."
fi


# --- Copy Wallpaper ---
if [ -f "$WALLPAPER_SRC" ]; then
    print_info "Copying wallpaper..."
    if cp "$WALLPAPER_SRC" "$WALLPAPER_DEST"; then
        print_success "Wallpaper copied to $WALLPAPER_DEST."
        # Verify copy
        if [ -f "$WALLPAPER_DEST" ]; then
            print_info " -> Wallpaper verified at destination."
        else
            print_warning " -> Wallpaper copy reported success, but file not found at $WALLPAPER_DEST!"
        fi
    else
        print_warning "Failed to copy wallpaper from $WALLPAPER_SRC to $WALLPAPER_DEST."
    fi
else
    print_warning "Wallpaper source file not found at '$WALLPAPER_SRC'. Skipping wallpaper copy."
fi

# --- Make Autostart Script Executable ---
AUTOSTART_SCRIPT="$CONFIG_DEST_DIR/qtile/autostart.sh"
if [ -f "$AUTOSTART_SCRIPT" ]; then
    print_info "Making autostart script executable..."
    if chmod +x "$AUTOSTART_SCRIPT"; then
        print_success "Autostart script is now executable."
    else
        print_warning "Failed to make autostart script executable: $AUTOSTART_SCRIPT"
    fi
else
    print_warning "Autostart script not found at $AUTOSTART_SCRIPT. Cannot make executable."
fi


# --- Final Instructions ---
echo
print_success "Installation script finished!"
echo "-----------------------------------------------------"
print_warning "Please review any warnings above."
echo
print_info "Next Steps & Troubleshooting:"
echo "1.  Log out of your current session."
echo "2.  If using a display manager (like LightDM, SDDM): Select 'Qtile' from the session menu before logging in."
echo "3.  If starting from TTY: Type 'startx' (ensure ~/.xinitrc contains 'exec qtile start')."
echo "      Create/edit ~/.xinitrc if needed:"
echo "      echo 'exec qtile start' > ~/.xinitrc && chmod +x ~/.xinitrc"
echo "4.  **If Wallpaper is Missing:**"
echo "      - Log into Qtile, open a terminal (Super+Enter)."
echo "      - Check if wallpaper exists: ls -l $WALLPAPER_DEST"
echo "      - If it exists, try setting it manually: feh --bg-fill $WALLPAPER_DEST"
echo "      - If that works, check for errors in Qtile's log: cat ~/.local/share/qtile/qtile.log"
echo "      - Ensure '$AUTOSTART_SCRIPT' is executable and has the correct 'feh' command."
echo "5.  **If Rofi is Not Themed:**"
echo "      - Check if Rofi configs exist: ls -l $CONFIG_DEST_DIR/rofi"
echo "      - Verify theme file name (e.g., 'catppuccin-mocha.rasi') exists."
echo "      - Check '$CONFIG_DEST_DIR/rofi/config.rasi'. Ensure the '@theme' line points to the correct filename (case-sensitive)."
echo "      - Ensure the font 'JetBrainsMono Nerd Font' is installed and available."
echo "6.  **(Recommended) Verify GTK/Icon Themes:**"
echo "      - Run 'lxappearance'. Select 'Catppuccin-Mocha-...' theme and 'Papirus-Dark' icons. Click Apply."
echo "7.  Enjoy your Catppuccin Qtile Rice!"
echo "-----------------------------------------------------"

exit 0
