# -*- coding: utf-8 -*-
# Qtile configuration file (Catppuccin Mocha flavor)
# Based on Catppuccin and default Qtile config

import os
import subprocess
from libqtile import bar, layout, widget, hook
from libqtile.config import Click, Drag, Group, Key, Match, Screen
from libqtile.lazy import lazy
from libqtile.utils import guess_terminal

# --- Catppuccin Mocha Colors ---
# Taken from https://github.com/catppuccin/catppuccin
catppuccin = {
    "rosewater": "#f5e0dc",
    "flamingo": "#f2cdcd",
    "pink": "#f5c2e7",
    "mauve": "#cba6f7",
    "red": "#f38ba8",
    "maroon": "#eba0ac",
    "peach": "#fab387",
    "yellow": "#f9e2af",
    "green": "#a6e3a1",
    "teal": "#94e2d5",
    "sky": "#89dceb",
    "sapphire": "#74c7ec",
    "blue": "#89b4fa",
    "lavender": "#b4befe",
    "text": "#cdd6f4",
    "subtext1": "#bac2de",
    "subtext0": "#a6adc8",
    "overlay2": "#9399b2",
    "overlay1": "#7f849c",
    "overlay0": "#6c7086",
    "surface2": "#585b70",
    "surface1": "#45475a",
    "surface0": "#313244",
    "base": "#1e1e2e",
    "mantle": "#181825",
    "crust": "#11111b",
}

# --- Settings ---
mod = "mod4"  # Super key (Windows key)
terminal = guess_terminal("alacritty") # Use Alacritty if found, otherwise fallback
# terminal = "alacritty" # Or force it
font_name = "JetBrainsMono Nerd Font"
font_size = 12
bar_size = 24

# --- Keybindings ---
keys = [
    # Switch between windows
    Key([mod], "h", lazy.layout.left(), desc="Move focus to left"),
    Key([mod], "l", lazy.layout.right(), desc="Move focus to right"),
    Key([mod], "j", lazy.layout.down(), desc="Move focus down"),
    Key([mod], "k", lazy.layout.up(), desc="Move focus up"),
    Key([mod], "space", lazy.layout.next(), desc="Move window focus to other window"),

    # Move windows between left/right columns or move up/down in current stack.
    Key([mod, "shift"], "h", lazy.layout.shuffle_left(), desc="Move window to the left"),
    Key([mod, "shift"], "l", lazy.layout.shuffle_right(), desc="Move window to the right"),
    Key([mod, "shift"], "j", lazy.layout.shuffle_down(), desc="Move window down"),
    Key([mod, "shift"], "k", lazy.layout.shuffle_up(), desc="Move window up"),

    # Grow windows. If current window is on the edge of screen and direction
    # will be to screen edge - window would shrink.
    Key([mod, "control"], "h", lazy.layout.grow_left(), desc="Grow window to the left"),
    Key([mod, "control"], "l", lazy.layout.grow_right(), desc="Grow window to the right"),
    Key([mod, "control"], "j", lazy.layout.grow_down(), desc="Grow window down"),
    Key([mod, "control"], "k", lazy.layout.grow_up(), desc="Grow window up"),
    Key([mod], "n", lazy.layout.normalize(), desc="Reset all window sizes"),

    # Toggle between split and unsplit sides of stack.
    Key([mod, "shift"], "Return", lazy.layout.toggle_split(), desc="Toggle split"),

    # Launch applications
    Key([mod], "Return", lazy.spawn(terminal), desc="Launch terminal"),
    Key([mod], "r", lazy.spawn("rofi -show drun"), desc="Spawn Rofi launcher"), # Changed from dmenu

    # Toggle between different layouts as defined below
    Key([mod], "Tab", lazy.next_layout(), desc="Toggle between layouts"),
    Key([mod, "shift"], "c", lazy.window.kill(), desc="Kill focused window"), # Changed from w

    # Qtile control
    Key([mod, "control"], "r", lazy.reload_config(), desc="Reload the config"),
    Key([mod, "control"], "q", lazy.shutdown(), desc="Shutdown Qtile"),
    Key([mod, "shift"], "r", lazy.spawncmd(), desc="Spawn a command using a prompt widget"), # Optional prompt

    # Volume control (Requires pamixer) - Install with 'sudo pacman -S pamixer'
    Key([], "XF86AudioLowerVolume", lazy.spawn("pamixer --decrease 5"), desc="Lower volume"),
    Key([], "XF86AudioRaiseVolume", lazy.spawn("pamixer --increase 5"), desc="Raise volume"),
    Key([], "XF86AudioMute", lazy.spawn("pamixer --toggle-mute"), desc="Mute volume"),

    # Brightness control (Requires brightnessctl) - Install with 'sudo pacman -S brightnessctl'
    Key([], "XF86MonBrightnessUp", lazy.spawn("brightnessctl set +5%"), desc="Increase brightness"),
    Key([], "XF86MonBrightnessDown", lazy.spawn("brightnessctl set 5%-"), desc="Decrease brightness"),
]

# --- Groups (Workspaces) ---
# group_names = "123456789" # Simple numbered groups
group_names = "" # Nerd Font Icons (Term, Web, Files, Code, Music, Video, Social, Chat, Games)
groups = [Group(i) for i in group_names]

for i, name in enumerate(group_names):
    index = str(i + 1)
    keys.extend(
        [
            # mod + number of group = switch to group
            Key([mod], index, lazy.group[name].toscreen(),
                desc="Switch to group {}".format(name)),
            # mod + shift + number of group = switch to & move focused window to group
            Key([mod, "shift"], index, lazy.window.togroup(name, switch_group=True),
                desc="Switch to & move focused window to group {}".format(name)),
            # Or mod + shift + letter of group = move focused window to group
            # Key([mod, "shift"], i.name, lazy.window.togroup(i.name),
            #     desc="move focused window to group {}".format(i.name)),
        ]
    )

# --- Layouts ---
layout_theme = {
    "border_width": 2,
    "margin": 6, # Gaps between windows
    "border_focus": catppuccin["mauve"],
    "border_normal": catppuccin["surface0"]
}

layouts = [
    layout.MonadTall(**layout_theme),
    layout.Max(**layout_theme),
    # layout.Stack(num_stacks=2, **layout_theme),
    # layout.Bsp(**layout_theme),
    # layout.Matrix(**layout_theme),
    # layout.MonadWide(**layout_theme),
    # layout.RatioTile(**layout_theme),
    # layout.Tile(**layout_theme),
    # layout.TreeTab(**layout_theme),
    # layout.VerticalTile(**layout_theme),
    # layout.Zoomy(**layout_theme),
    # layout.Floating(**layout_theme) # Keep floating last potentially
]

# --- Widgets ---
widget_defaults = dict(
    font=font_name,
    fontsize=font_size,
    padding=3,
    background=catppuccin["base"] # Bar background color
)
extension_defaults = widget_defaults.copy()

def get_widgets(primary=False):
    widgets = [
         widget.GroupBox(
            fontsize=font_size + 4, # Larger icons
            margin_y=3,
            margin_x=5,
            padding_y=5,
            padding_x=5,
            borderwidth=3,
            active=catppuccin["text"],
            inactive=catppuccin["overlay0"],
            rounded=True,
            highlight_method="block", # or "line" or "text"
            this_current_screen_border=catppuccin["mauve"], # Color of active workspace on current screen
            this_screen_border=catppuccin["green"], # Color of active workspace on other screen (if any)
            other_current_screen_border=catppuccin["mauve"],
            other_screen_border=catppuccin["green"],
            foreground=catppuccin["text"],
            background=catppuccin["mantle"], # Slightly different background for groupbox
            disable_drag=True,
        ),
        widget.TextBox(
            text='|',
            font=font_name,
            background=catppuccin["mantle"],
            foreground=catppuccin["surface1"],
            padding=2,
            fontsize=font_size + 2
        ),
        widget.WindowName(
            foreground=catppuccin["mauve"],
            background=catppuccin["mantle"],
            padding=5,
            max_chars=40 # Limit length
        ),
        widget.Spacer( # Pushes widgets to the right
             background=catppuccin["base"], # Match bar background
        ),
        # Optional prompt widget if you like it
        # widget.Prompt(
        #      foreground=catppuccin["rosewater"],
        #      background=catppuccin["surface0"]
        # ),
        widget.Systray(
             background=catppuccin["base"],
             padding=5
        ),
         widget.TextBox(
            text=' ', # Spacer before next section
            background=catppuccin["base"],
         ),
        # Section background
         widget.TextBox(
            text="", # CPU Icon
            foreground=catppuccin["base"],
            background=catppuccin["red"],
            padding = 5,
            fontsize = font_size + 2
        ),
         widget.CPU(
            format='{load_percent}%',
            foreground=catppuccin["base"],
            background=catppuccin["red"],
            padding=5,
            update_interval=2.0
         ),
         widget.TextBox(
            text="󰍛", # Memory Icon
            foreground=catppuccin["base"],
            background=catppuccin["peach"],
            padding = 5,
            fontsize = font_size + 2
        ),
        widget.Memory(
            foreground=catppuccin["base"],
            background=catppuccin["peach"],
            fmt='{}', # Default is fine
            padding=5,
            measure_mem='G', # Show in GiB
            update_interval=2.0
         ),
        # Uncomment if you installed python-iwlib and have wifi
        # widget.TextBox(
        #    text="󰖩", # Wifi Icon
        #    foreground=catppuccin["base"],
        #    background=catppuccin["yellow"],
        #    padding = 5,
        #    fontsize = font_size + 2
        # ),
        # widget.Wlan(
        #    interface="wlan0", # CHANGE THIS to your wifi interface name (e.g., wlp3s0)
        #    format='{essid} {percent:2.0%}',
        #    foreground=catppuccin["base"],
        #    background=catppuccin["yellow"],
        #    padding=5,
        #    update_interval=5.0,
        #    disconnected_message='Disconnected',
        # ),
        widget.TextBox(
            text="󰕾", # Volume Icon
            foreground=catppuccin["base"],
            background=catppuccin["green"],
            padding = 5,
            fontsize = font_size + 2
        ),
         widget.PulseVolume( # Requires pulseaudio or pipewire-pulse
            foreground=catppuccin["base"],
            background=catppuccin["green"],
            fmt='{}',
            padding=5,
            update_interval=0.1,
            # Use these step/mouse callbacks if default clicks don't work well
            # step=5,
            # mouse_callbacks = {'Button1': lazy.spawn("pavucontrol")}, # Open volume control on click
         ),
         widget.TextBox(
            text="󰃭", # Clock Icon
            foreground=catppuccin["base"],
            background=catppuccin["blue"],
            padding = 5,
            fontsize = font_size + 2
        ),
        widget.Clock(
            format="%Y-%m-%d %a %I:%M %p", # Example: 2023-10-27 Fri 02:30 PM
            foreground=catppuccin["base"],
            background=catppuccin["blue"],
            padding=5
        ),
        widget.TextBox(
            text="", # Power Icon (optional)
            foreground=catppuccin["base"],
            background=catppuccin["lavender"],
            padding = 10,
            fontsize = font_size + 2,
            mouse_callbacks = {'Button1': lazy.shutdown()} # Careful with this! Click to shutdown
        ),
    ]
    # Remove systray on non-primary monitors (if you have multiple)
    # if not primary:
    #     widgets.pop(widgets.index(widget.Systray())) # Adjust index if layout changes
    return widgets

# --- Screens ---
screens = [
    Screen(
        top=bar.Bar(
            get_widgets(primary=True),
            bar_size,
            opacity=0.95 # Slightly transparent bar
            # border_width=[2, 0, 2, 0],  # Draw top and bottom borders
            # border_color=["ff00ff", "000000", "ff00ff", "000000"]  # Borders are magenta
        ),
    ),
    # Add more Screen objects if you have multiple monitors
    # Screen(
    #     top=bar.Bar(
    #         get_widgets(primary=False), # Get widgets without systray etc.
    #         bar_size,
    #         opacity=0.95
    #     ),
    # ),
]

# --- Mouse Bindings ---
# Drag floating layouts.
mouse = [
    Drag([mod], "Button1", lazy.window.set_position_floating(), start=lazy.window.get_position()),
    Drag([mod], "Button3", lazy.window.set_size_floating(), start=lazy.window.get_size()),
    Click([mod], "Button2", lazy.window.bring_to_front()),
]

# --- Floating Layout ---
dgroups_key_binder = None
dgroups_app_rules = []  # type: list
follow_mouse_focus = True
bring_front_click = False
cursor_warp = False
floating_layout = layout.Floating(
    float_rules=[
        # Run the utility of `xprop` to see the wm class and name of an X client.
        *layout.Floating.default_float_rules,
        Match(wm_class="confirmreset"),  # gitk
        Match(wm_class="makebranch"),  # gitk
        Match(wm_class="maketag"),  # gitk
        Match(wm_class="ssh-askpass"),  # ssh-askpass
        Match(title="branchdialog"),  # gitk
        Match(title="pinentry"),  # GPG key password entry
        Match(wm_class="lxappearance"),
        Match(wm_class="pavucontrol"), # PulseAudio Volume Control
    ],
    border_focus=catppuccin["pink"], # Different border for floating windows
    border_normal=catppuccin["surface1"],
    border_width=2,
    fullscreen_border_width=0,
    max_border_width=0,
)
auto_fullscreen = True
focus_on_window_activation = "smart" # or "focus" or "urgent"
reconfigure_screens = True

# If things like steam games want to auto-minimize themselves when losing
# focus, should we respect this or not?
auto_minimize = True

# When using the Wayland backend, this can be used to configure input devices.
wl_input_rules = None

# --- Autostart ---
# Programs to start automatically when Qtile starts. Run only once.
@hook.subscribe.startup_once
def autostart():
    home = os.path.expanduser('~/.config/qtile/autostart.sh')
    subprocess.Popen([home]) # Use Popen to run in background

# XXX: Gasp! We're lying here. In fact, nobody really uses or cares about this
# string besides java UI toolkits; you can see several discussions on the
# mailing lists, GitHub issues, and other WM documentation that suggest setting
# this string if your java app doesn't work correctly. We may as well just lie
# and say that we're a working one by default.
#
# We choose LG3D to maximize irony: it is a 3D non-reparenting WM written in
# java that happens to be on java's whitelist.
wmname = "LG3D" # Essential for Java applications
