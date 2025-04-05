# Qtile Catppuccin Mocha Rice

![Screenshot Placeholder](placeholder.png) <!-- Replace placeholder.png with an actual screenshot URL/path later -->

A minimal but functional Qtile rice using the Catppuccin Mocha theme for Arch Linux.

## Features

*   **Window Manager:** Qtile
*   **Theme:** Catppuccin (Mocha flavor)
*   **Terminal:** Alacritty
*   **Launcher:** Rofi
*   **Compositor:** Picom (basic config for transparency/shadows)
*   **Notifications:** Dunst
*   **Bar:** Qtile's built-in bar with common widgets (Workspaces, Window Name, CPU, RAM, Volume, Clock)
*   **Font:** JetBrainsMono Nerd Font (for icons in the bar)
*   **GTK/Icons:** Includes automated setup for Catppuccin GTK themes and Papirus icons (Catppuccin folder colors).

## Prerequisites

*   A base Arch Linux installation.
*   Internet connection.
*   `sudo` privileges for your user.
*   `git` installed (`sudo pacman -S git --needed --noconfirm`).

## Installation

**Warning:** This script will overwrite existing configuration files for Qtile, Alacritty, Rofi, Picom, and Dunst in your `~/.config` directory. Back up any important configurations first!

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/YOUR_USERNAME/qtile-catppuccin-rice.git # Replace YOUR_USERNAME
    cd qtile-catppuccin-rice
    ```

2.  **Make the install script executable:**
    ```bash
    chmod +x install.sh
    ```

3.  **Run the installation script:**
    ```bash
    ./install.sh
    ```
    The script will ask for confirmation and your `sudo` password when needed.

4.  **Set up `~/.xinitrc` (if not using a Display Manager):**
    If you plan to start your graphical session from the TTY using `startx`, ensure your `~/.xinitrc` file executes Qtile:
    ```bash
    echo "exec qtile start" > ~/.xinitrc
    chmod +x ~/.xinitrc
    ```

5.  **Reboot or Log Out:**
    Log out of your current session or reboot your machine.

6.  **Log In:**
    *   **With Display Manager (LightDM, SDDM, etc.):** Select "Qtile" from the session list/menu before entering your password.
    *   **From TTY:** Log in with your username and password, then type `startx`.

7.  **(Recommended) Verify GTK/Icon Themes:**
    Once logged into Qtile, open a terminal (`Super + Enter`) and run:
    ```bash
    lxappearance
    ```
    Verify that a Catppuccin theme (e.g., `Catppuccin-Mocha-Standard-Mauve-Dark`) is selected under "Widget" and `Papirus-Dark` (or similar) is selected under "Icon Theme". Apply if necessary.

## Keybindings (Default - check `config.py` for details)

*   `Super + Enter`: Launch Terminal (Alacritty)
*   `Super + r`: Launch Application Launcher (Rofi)
*   `Super + h/j/k/l`: Navigate windows
*   `Super + Shift + h/j/k/l`: Move windows
*   `Super + Ctrl + h/j/k/l`: Resize windows
*   `Super + Tab`: Cycle layouts
*   `Super + Shift + c`: Kill focused window
*   `Super + [1-9]`: Switch to workspace
*   `Super + Shift + [1-9]`: Move focused window to workspace
*   `Super + Control + r`: Reload Qtile configuration
*   `Super + Control + q`: Quit Qtile
*   **(Media Keys):** Standard XF86 Volume Up/Down/Mute and Brightness Up/Down should work if `pamixer` and `brightnessctl` are correctly installed and configured.

## Customization

*   **Qtile:** Edit `~/.config/qtile/config.py`. Reload with `Super + Control + r`.
*   **Theme Flavor:** Edit the color palette in `config.py`. Also update theme references in `alacritty.toml`, `rofi/config.rasi`, and `dunst/dunstrc`. Remember to potentially re-run `sudo papirus-folders -C <new-catppuccin-color> ...`
*   **Wallpaper:** Replace `~/.config/qtile/wallpaper.jpg` and reload Qtile or restart the `feh` command.
*   **Autostart Apps:** Edit `~/.config/qtile/autostart.sh`.

## Troubleshooting

*   If Qtile fails to start or the bar looks wrong, check the log file: `~/.local/share/qtile/qtile.log`.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details (if included).

## Acknowledgements

*   [Qtile](http://www.qtile.org/)
*   [Catppuccin Theme](https://github.com/catppuccin)
*   [Alacritty](https://github.com/alacritty/alacritty)
*   [Rofi](https://github.com/davatorium/rofi)
*   [Picom](https://github.com/yshui/picom)
*   [Dunst](https://dunst-project.org/)
*   [JetBrains Mono Font](https://www.jetbrains.com/lp/mono/)
*   [Papirus Icon Theme](https://github.com/PapirusDevelopmentTeam/papirus-icon-theme)
*   [Papirus Folders](https://github.com/PapirusDevelopmentTeam/papirus-folders)
