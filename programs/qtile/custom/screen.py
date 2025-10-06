import os
from pathlib import Path

from libqtile import bar, qtile, widget
from libqtile.config import Screen

from custom.default import extension_defaults
from custom.extras.snake import Snake
from custom.extras.tetris import Tetris
from custom.layout import ScreenLayout
from custom.utils import OS, determine_os, mount_exists
from custom.widget import Krill, MaxCPUGraph, StandardWidgetBox, WallpaperDir, Weather

BATTERY_PATHS = [
    Path("/sys/class/power_supply/BAT0"),
    Path("/sys/class/power_supply/BAT1"),
]
WALLPAPER_DIR = Path("~/Pictures/wallpapers")
HOME_DIR = "/home"
ROOT_DIR = "/"
TERM = "kitty"

disk_widgets = [
    widget.DF(
        visible_on_warn=False,
        font=extension_defaults.font,
        fontsize=extension_defaults.fontsize,
        foreground=extension_defaults.foreground,
        format="{p}: {r:.0f}%",
        partition=ROOT_DIR,
        mouse_callbacks={"Button1": lambda: qtile.spawn(f"{TERM} -bx ncdu {ROOT_DIR}")},
    ),
]

if mount_exists(HOME_DIR):
    disk_widgets.append(
        widget.DF(
            visible_on_warn=False,
            foreground=extension_defaults.foreground,
            format="{p}: {r:.0f}%",
            partition=HOME_DIR,
            mouse_callbacks={
                "Button1": lambda: qtile.spawn(f"{TERM} -bx ncdu {HOME_DIR}")
            },
        )
    )


top_widgets = [
    widget.Spacer(length=10),
    widget.WindowName(
        for_current_screen=True,
        font=extension_defaults.font,
        fontsize=extension_defaults.fontsize,
    ),
    Snake(
        size=4,
    ),
    widget.Spacer(length=10),
    StandardWidgetBox(
        widgets=(
            widget.Spacer(length=10),
            WallpaperDir(
                directory=WALLPAPER_DIR.expanduser(),
                foreground=extension_defaults.foreground,
                font=extension_defaults.font,
                fontsize=extension_defaults.fontsize,
                update_interval=30,
                debug=False,
            ),
        ),
        background=extension_defaults.red,
        foreground=extension_defaults.black,
        text_closed="WP",
    ),
    widget.Spacer(length=10),
    StandardWidgetBox(
        widgets=disk_widgets,
        text_closed="Disk",
        background=extension_defaults.orange,
        foreground=extension_defaults.black,
    ),
    widget.Spacer(length=10),
    StandardWidgetBox(
        widgets=(
            widget.MemoryGraph(
                graph_color=extension_defaults.foreground,
                mouse_callbacks={"Button1": lambda: qtile.spawn(f"{TERM} -bx htop")},
                samples=40,  # FIX: Weird graph issue where only drawing on left
                border_width=2,
                border_color="000000",
                font=extension_defaults.font,
                fontsize=extension_defaults.fontsize,
            ),
        ),
        text_closed="Mem",
        background=extension_defaults.yellow,
        foreground=extension_defaults.black,
    ),
    widget.Spacer(length=10),
    StandardWidgetBox(
        widgets=(
            MaxCPUGraph(
                graph_color=extension_defaults.foreground,
                mouse_callbacks={"Button1": lambda: qtile.spawn(f"{TERM} -bx htop")},
                samples=40,  # FIX: Weird graph issue where only drawing on left
                border_width=2,
                border_color="000000",
                font=extension_defaults.font,
                fontsize=extension_defaults.fontsize,
            ),
        ),
        text_closed="Cpu",
        background=extension_defaults.green,
        foreground=extension_defaults.black,
    ),
    widget.Spacer(length=10),
    StandardWidgetBox(
        widgets=(
            widget.Net(
                foreground=extension_defaults.foreground,
                font=extension_defaults.font,
                fontsize=extension_defaults.fontsize,
                interface=os.environ.get("QTILE_NET_INTERFACE"),
                format="{down:3.0f}{down_suffix:2} ↓↑ {up:3.0f}{up_suffix:2}",
                update_interval=2,
            ),
        ),
        text_closed="Net",
        background=extension_defaults.blue,
        foreground=extension_defaults.white,
    ),
]

machine_os = determine_os()

if machine_os == OS.Ubuntu:
    top_widgets.extend(
        [
            widget.TextBox(
                "U:",
                font=extension_defaults.font,
                fontsize=extension_defaults.fontsize,
            ),
            widget.CheckUpdates(
                display_format="{updates}",
                distro="Ubuntu",
                foreground=extension_defaults.foreground,
                colour_no_updates=extension_defaults.foreground,
                colour_have_updates=extension_defaults.foreground,
                update_interval=3600,  # update every hour
                restart_indicator="*",
                no_update_string="0",
                font=extension_defaults.font,
                fontsize=extension_defaults.fontsize,
            ),
        ]
    )
elif machine_os in (OS.Manjaro, OS.Garuda, OS.Arch):
    top_widgets.extend(
        [
            widget.TextBox(
                "U:",
                font=extension_defaults.font,
                fontsize=extension_defaults.fontsize,
            ),
            widget.CheckUpdates(
                font=extension_defaults.font,
                fontsize=extension_defaults.fontsize,
                display_format="{updates}",
                distro="Arch",
                custom_command=(
                    r"""
pamac checkupdates | awk 'BEGIN{RS="\n\n";FS=OFS="\n"} NR==1 {print $0}' | awk 'NR==1 {if($0!~/available/){exit}} NR>1 {print $0}' | grep -v "^$"
                            """
                ),
                foreground=extension_defaults.foreground,
                colour_no_updates=extension_defaults.foreground,
                colour_have_updates=extension_defaults.foreground,
                update_interval=3600,  # update every hour
                no_update_string="0",
            ),
        ]
    )

top_widgets.extend(
    [
        widget.Spacer(length=10),
        StandardWidgetBox(
            widgets=(
                Weather(
                    normal_foreground=extension_defaults.foreground,
                    update_interval=3600,  # Update every hour
                    font=extension_defaults.font,
                    fontsize=extension_defaults.fontsize,
                    debug=False,
                ),
            ),
            text_closed="Wea",
            background=extension_defaults.indigo,
            foreground=extension_defaults.white,
        ),
    ]
)

if any([path.exists() for path in BATTERY_PATHS]):
    top_widgets.extend(
        [
            widget.Spacer(length=10),
            StandardWidgetBox(
                widgets=(
                    widget.Battery(
                        energy_now_file="charge_now",
                        energy_full_file="charge_full",
                        power_now_file="current_now",
                        charge_char="↗",
                        discharge_char="↘",
                        low_percentage=0.3,
                        charging_foreground=extension_defaults.foreground_green,
                        foreground=extension_defaults.foreground,
                        format="{char}{percent:2.0%}",
                        font=extension_defaults.font,
                        fontsize=extension_defaults.fontsize,
                    ),
                ),
                text_closed="Bat",
                start_opened=True,
                background=extension_defaults.violet,
                foreground=extension_defaults.white,
            ),
        ]
    )

top_widgets.extend(
    [
        widget.Spacer(length=10),
        StandardWidgetBox(
            widgets=(
                widget.Volume(
                    foreground=extension_defaults.foreground,
                    font=extension_defaults.font,
                    fontsize=extension_defaults.fontsize,
                ),
            ),
            text_closed="Vol",
            start_opened=True,
            background=extension_defaults.black,
            foreground=extension_defaults.white,
        ),
        widget.Systray(icon_size=extension_defaults.iconsize),
        widget.Clock(
            foreground=extension_defaults.foreground_yellow,
            format="%a %b %d %H:%M:%S",
            font=extension_defaults.font,
            fontsize=extension_defaults.fontsize,
        ),
        # widget.Notify(
        #     font=extension_defaults.font,
        #     fontsize=extension_defaults.fontsize,
        # )
        widget.Spacer(length=10),
    ]
)

SCREENS = [
    Screen(
        top=bar.Bar(
            top_widgets,
            extension_defaults.bar_thickness,
            margin=extension_defaults.bar_margin,
        ),
        bottom=bar.Bar(
            [
                widget.Spacer(length=10),
                widget.GroupBox(
                    this_current_screen_border=extension_defaults.foreground,
                    this_screen_border=extension_defaults.inactive_foreground,
                    other_current_screen_border=extension_defaults.foreground,
                    other_screen_border=extension_defaults.inactive_foreground,
                    font=extension_defaults.font,
                    fontsize=extension_defaults.fontsize,
                    use_mouse_wheel=False,
                    mouse_callbacks={"Button1": lambda: None},
                ),
                widget.Spacer(length=10),
                ScreenLayout(
                    # width=bar.STRETCH,
                    foreground=extension_defaults.foreground_yellow,
                    font=extension_defaults.font,
                    fontsize=extension_defaults.fontsize,
                ),
                Tetris(
                    # length=150,
                    blockify=True,
                    mouse_callbacks={"Button1": lambda: None},
                ),
                widget.Spacer(length=10),
                widget.TextBox(
                    "Krl:",
                    font=extension_defaults.font,
                    fontsize=extension_defaults.fontsize,
                ),
                Krill(
                    foreground=extension_defaults.foreground,
                    update_interval=21,
                    font=extension_defaults.font,
                    fontsize=extension_defaults.fontsize,
                    debug=False,
                ),
                widget.Spacer(length=10),
            ],
            extension_defaults.bar_thickness,
            margin=extension_defaults.bar_margin,
        ),
    ),
]
