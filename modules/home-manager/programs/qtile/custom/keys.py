from libqtile.config import Key

try:
    from libqtile.lazy import lazy
except ImportError:
    from libqtile.command import lazy  # Soon to be deprecated
from custom.constants import (
    MOD,
    SHIFT,
    CONTROL,
    SPACE,
    PERIOD,
    COMMA,
    ENTER,
)

QTILE_CONFIG_DIRECTORY = "~/.config/qtile"


@lazy.function
def to_screen(qtile, index):
    screens = sorted(qtile.get_screens(), key=lambda x: x["x"])
    screens = [x["index"] for x in screens]
    if len(screens) == 1:
        screen_positions = 0, 0, 0
    elif len(screens) == 2:
        screen_positions = screens[0], screens[1], screens[1]
    else:
        screen_positions = screens[0], screens[2], screens[1]

    qtile.to_screen(screen_positions[index])


KEYS = [
    Key([MOD], "j", lazy.group.next_window()),
    Key([MOD], "k", lazy.group.prev_window()),
    Key([MOD], "h", lazy.layout.shrink_main()),
    Key([MOD], "l", lazy.layout.grow_main()),
    Key([MOD, SHIFT], "h", lazy.layout.shrink()),
    Key([MOD, SHIFT], "l", lazy.layout.grow()),
    Key([MOD], "n", lazy.layout.normalize()),
    Key([MOD], "m", lazy.layout.maximize()),
    # Move windows up or down in current stack
    Key([MOD, SHIFT], "j", lazy.layout.shuffle_down()),
    Key([MOD, SHIFT], "k", lazy.layout.shuffle_up()),
    Key([MOD], ENTER, lazy.layout.swap_main()),
    # Multi-monitor support
    Key([MOD], "w", to_screen(0)),
    Key([MOD], "e", to_screen(1)),
    Key([MOD], "r", to_screen(2)),
    Key([MOD, CONTROL], "1", lazy.spawn("qtile-one-screen")),
    Key([MOD, CONTROL], "2", lazy.spawn("qtile-two-screen")),
    Key([MOD, CONTROL], "3", lazy.spawn("qtile-three-screen")),
    # Swap main pane
    Key([MOD], "f", lazy.layout.flip()),
    Key([MOD, SHIFT], "f", lazy.window.toggle_fullscreen()),
    # Floating
    Key([MOD], "t", lazy.window.toggle_floating()),
    # Open a new terminal
    Key([MOD, SHIFT], ENTER, lazy.spawn("kitty --single-instance")),
    # Toggle between different layouts as defined below
    Key([MOD], SPACE, lazy.next_layout()),
    Key([MOD, SHIFT], "c", lazy.window.kill()),
    Key([MOD, CONTROL], "r", lazy.spawn("qtile cmd-obj -o cmd -f reload_config")),
    Key([MOD, CONTROL], "l", lazy.spawn("force-lock-screen")),
    Key([MOD, CONTROL], "p", lazy.spawn("toggle-picom")),
    Key([MOD], "p", lazy.spawn("rofi -show drun -modi drun,calc,emoji -no-history")),
    Key(
        [MOD, CONTROL],
        "q",
        lazy.spawn("rofi -show power-menu -modi power-menu:rofi-power-menu"),
    ),
    # Spotify Commands
    # NEXT
    Key(
        [],
        "XF86AudioNext",
        lazy.spawn(
            "dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.Next"
        ),
    ),
    Key(
        [MOD, CONTROL],
        PERIOD,
        lazy.spawn(
            "dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.Next"
        ),
    ),
    # PREV
    Key(
        [],
        "XF86AudioPrev",
        lazy.spawn(
            "dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.Previous"
        ),
    ),
    Key(
        [MOD, CONTROL],
        COMMA,
        lazy.spawn(
            "dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.Previous"
        ),
    ),
    # PAUSE
    Key(
        [],
        "XF86AudioPlay",
        lazy.spawn(
            "dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.PlayPause"
        ),
    ),
    Key(
        [MOD, CONTROL],
        SPACE,
        lazy.spawn(
            "dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.PlayPause"
        ),
    ),
    # Volume Controls
    Key([], "XF86AudioRaiseVolume", lazy.spawn("amixer -q set Master 10%+")),
    Key([], "XF86AudioLowerVolume", lazy.spawn("amixer -q set Master 10%-")),
    Key([], "XF86AudioMute", lazy.spawn("amixer -q set Master toggle")),
    # Brightness Controls
    Key([], "XF86MonBrightnessUp", lazy.spawn("brightnessctl s +10%")),
    Key([], "XF86MonBrightnessDown", lazy.spawn("brightnessctl s 10%-")),
    Key([MOD], "F11", lazy.group["scratchpad"].dropdown_toggle("term")),
    Key([MOD], "F12", lazy.group["scratchpad"].dropdown_toggle("browser")),
    Key([MOD], "F6", lazy.group["scratchpad"].dropdown_toggle("browser")),
    Key(
        [],
        "Print",
        lazy.spawn(
            "scrot 'screenshot_%Y%m%d_%H%M%S.png' -e 'mkdir -p ~/Pictures/screenshots && mv $f ~/Pictures/screenshots && xclip -selection clipboard -t image/png -i ~/Pictures/screenshots/`ls -1 -t ~/Pictures/screenshots | head -1`'"
        ),
    ),
    Key(
        ["shift"],
        "Print",
        lazy.spawn(
            "scrot -s 'screenshot_%Y%m%d_%H%M%S.png' -e 'mkdir -p ~/Pictures/screenshots && mv $f ~/Pictures/screenshots && xclip -selection clipboard -t image/png -i ~/Pictures/screenshots/`ls -1 -t ~/Pictures/screenshots | head -1`'"
        ),
    ),
]
