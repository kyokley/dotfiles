import os
from pathlib import Path

from libqtile import bar, qtile, widget
from libqtile.config import Screen

from custom.default import extension_defaults
from custom.extras.snake import Snake
from custom.extras.tetris import Tetris
from custom.layout import ScreenLayout
from custom.utils import mount_exists
from custom.widget import (
    Krill,
    StandardWidgetBox,
    WallpaperDir,
    Weather,
    WeatherWidgetBox,
    BatteryWidgetBox,
    VolumeWidgetBox,
    CustomVolume,
    CustomBattery,
    CustomWindowNameEndcap,
    TailscaleNetWidgetBox,
    TailscaleNet,
    DFWidgetBox,
    CustomDF,
    CustomMemoryGraph,
    MemoryGraphWidgetBox,
    CustomCPUGraph,
    CPUGraphWidgetBox,
)

BATTERY_PATHS = [
    Path("/sys/class/power_supply/BAT0"),
    Path("/sys/class/power_supply/BAT1"),
]
WALLPAPER_DIR = Path("~/Pictures/wallpapers")
HOME_DIR = "/home"
ROOT_DIR = "/"
TERM = "kitty"

disk_widgets = [
    CustomDF(
        visible_on_warn=False,
        font=extension_defaults.font,
        fontsize=extension_defaults.fontsize,
        foreground=extension_defaults.black,
        background=extension_defaults.orange,
        format="{p}: {r:.0f}%",
        partition=ROOT_DIR,
        mouse_callbacks={"Button1": lambda: qtile.spawn(f"{TERM} -bx ncdu {ROOT_DIR}")},
        warn_space=50,
        measurement="G",
    ),
]

if mount_exists(HOME_DIR):
    disk_widgets.append(
        widget.DF(
            visible_on_warn=False,
            foreground=extension_defaults.black,
            background=extension_defaults.orange,
            format="{p}: {r:.0f}%",
            partition=HOME_DIR,
            mouse_callbacks={
                "Button1": lambda: qtile.spawn(f"{TERM} -bx ncdu {HOME_DIR}")
            },
        )
    )


def parse_text(text):
    for string in (
        " - Chromium",
        " - Firefox",
        " - Brave",
        " - Outlook",
        " - Slack",
    ):
        text = text.replace(string, "")
    return text


top_widgets = [
    widget.Spacer(length=10),
    CustomWindowNameEndcap(
        "",
        font=extension_defaults.font,
        fontsize=extension_defaults.endcap_fontsize,
        foreground=extension_defaults.black,
        padding=0,
        for_current_screen=True,
    ),
    widget.WindowName(
        name="WindowName",
        for_current_screen=True,
        font=extension_defaults.font,
        fontsize=extension_defaults.fontsize,
        background=extension_defaults.black,
        parse_text=parse_text,
        scroll=True,
        scroll_delay=0,
        scroll_interval=0.05,
        scroll_clear=True,
        scroll_step=1,
        width=350,
        empty_group_string="",
    ),
    CustomWindowNameEndcap(
        "",
        font=extension_defaults.font,
        fontsize=extension_defaults.endcap_fontsize,
        foreground=extension_defaults.black,
        padding=0,
        for_current_screen=True,
    ),
    Tetris(
        name="Tetris",
        blockify=True,
        mouse_callbacks={
            "Button1": lambda: qtile.widgets_map.get("Tetris").start(),
            "Button3": lambda: qtile.widgets_map.get("Tetris").stop(),
        },
        autostart=False,
    ),
    widget.Spacer(length=10),
    widget.TextBox(
        "",
        font=extension_defaults.font,
        fontsize=extension_defaults.endcap_fontsize,
        foreground=extension_defaults.red,
        padding=0,
    ),
    StandardWidgetBox(
        widgets=(
            WallpaperDir(
                directory=WALLPAPER_DIR.expanduser(),
                background=extension_defaults.red,
                foreground=extension_defaults.black,
                font=extension_defaults.font,
                fontsize=extension_defaults.fontsize,
                update_interval=600,
                debug=False,
            ),
        ),
        background=extension_defaults.red,
        foreground=extension_defaults.black,
        text_closed="󰸉",
        fontsize=extension_defaults.widget_box_iconsize,
        start_opened=False,
    ),
    widget.TextBox(
        "",
        font=extension_defaults.font,
        fontsize=extension_defaults.endcap_fontsize,
        foreground=extension_defaults.red,
        padding=0,
    ),
    widget.Spacer(length=10),
    widget.TextBox(
        "",
        font=extension_defaults.font,
        fontsize=extension_defaults.endcap_fontsize,
        foreground=extension_defaults.orange,
        padding=0,
    ),
    DFWidgetBox(
        widgets=disk_widgets,
        text_closed="\uf0c7",
        background=extension_defaults.orange,
        foreground=extension_defaults.black,
        fontsize=extension_defaults.widget_box_iconsize,
    ),
    widget.TextBox(
        "",
        font=extension_defaults.font,
        fontsize=extension_defaults.endcap_fontsize,
        foreground=extension_defaults.orange,
        padding=0,
    ),
    widget.Spacer(length=10),
    widget.TextBox(
        "",
        font=extension_defaults.font,
        fontsize=extension_defaults.endcap_fontsize,
        foreground=extension_defaults.yellow,
        padding=0,
    ),
    MemoryGraphWidgetBox(
        widgets=(
            CustomMemoryGraph(
                graph_color=extension_defaults.foreground,
                mouse_callbacks={"Button1": lambda: qtile.spawn(f"{TERM} -bx htop")},
                samples=40,
                border_width=0,
                border_color=extension_defaults.yellow,
                font=extension_defaults.font,
                fontsize=extension_defaults.fontsize,
                background=extension_defaults.yellow,
                warning_threshold=75,
            ),
        ),
        text_closed="\uefc5",
        background=extension_defaults.yellow,
        foreground=extension_defaults.black,
        fontsize=extension_defaults.widget_box_iconsize,
    ),
    widget.TextBox(
        "",
        font=extension_defaults.font,
        fontsize=extension_defaults.endcap_fontsize,
        foreground=extension_defaults.yellow,
        padding=0,
    ),
    widget.Spacer(length=10),
    widget.TextBox(
        "",
        font=extension_defaults.font,
        fontsize=extension_defaults.endcap_fontsize,
        foreground=extension_defaults.green,
        padding=0,
    ),
    CPUGraphWidgetBox(
        widgets=(
            CustomCPUGraph(
                graph_color=extension_defaults.foreground,
                mouse_callbacks={"Button1": lambda: qtile.spawn(f"{TERM} -bx htop")},
                samples=40,  # FIX: Weird graph issue where only drawing on left
                border_width=0,
                border_color=extension_defaults.green,
                font=extension_defaults.font,
                fontsize=extension_defaults.fontsize,
                background=extension_defaults.green,
                warning_threshold=80,
                debug=False,
            ),
        ),
        text_closed="\uf4bc",
        background=extension_defaults.green,
        foreground=extension_defaults.black,
        fontsize=extension_defaults.widget_box_iconsize,
    ),
    widget.TextBox(
        "",
        font=extension_defaults.font,
        fontsize=extension_defaults.endcap_fontsize,
        foreground=extension_defaults.green,
        padding=0,
    ),
    widget.Spacer(length=10),
    widget.TextBox(
        "",
        font=extension_defaults.font,
        fontsize=extension_defaults.endcap_fontsize,
        foreground=extension_defaults.cyan,
        padding=0,
    ),
    TailscaleNetWidgetBox(
        widgets=(
            TailscaleNet(
                foreground=extension_defaults.black,
                background=extension_defaults.cyan,
                font=extension_defaults.font,
                fontsize=extension_defaults.fontsize,
                interface=os.environ.get("QTILE_NET_INTERFACE"),
                format="{down:3.0f}{down_suffix:2} ↓↑ {up:3.0f}{up_suffix:2}",
                update_interval=2,
                debug=False,
            ),
        ),
        text_closed="\uef09",
        background=extension_defaults.cyan,
        foreground=extension_defaults.black,
        fontsize=extension_defaults.widget_box_iconsize,
    ),
    widget.TextBox(
        "",
        font=extension_defaults.font,
        fontsize=extension_defaults.endcap_fontsize,
        foreground=extension_defaults.cyan,
        padding=0,
    ),
]


if any([path.exists() for path in BATTERY_PATHS]):
    top_widgets.extend(
        [
            widget.Spacer(length=10),
            widget.TextBox(
                "",
                font=extension_defaults.font,
                fontsize=extension_defaults.endcap_fontsize,
                foreground=extension_defaults.blue,
                padding=0,
            ),
            BatteryWidgetBox(
                widgets=(
                    CustomBattery(
                        energy_now_file="charge_now",
                        energy_full_file="charge_full",
                        power_now_file="current_now",
                        charge_char="↗",
                        discharge_char="↘",
                        low_percentage=0.3,
                        charging_foreground=extension_defaults.green,
                        foreground=extension_defaults.white,
                        background=extension_defaults.blue,
                        format="{char}{percent:2.0%}",
                        font=extension_defaults.font,
                        fontsize=extension_defaults.fontsize,
                    ),
                ),
                text_closed="",
                background=extension_defaults.blue,
                foreground=extension_defaults.white,
                fontsize=extension_defaults.widget_box_iconsize,
                start_opened=False,
            ),
            widget.TextBox(
                "",
                font=extension_defaults.font,
                fontsize=extension_defaults.endcap_fontsize,
                foreground=extension_defaults.blue,
                padding=0,
            ),
        ]
    )

top_widgets.extend(
    [
        widget.Spacer(length=10),
        widget.TextBox(
            "",
            font=extension_defaults.font,
            fontsize=extension_defaults.endcap_fontsize,
            foreground=extension_defaults.indigo,
            padding=0,
        ),
        WeatherWidgetBox(
            widgets=(
                Weather(
                    normal_foreground=extension_defaults.white,
                    background=extension_defaults.indigo,
                    update_interval=3600,  # Update every hour
                    font=extension_defaults.font,
                    fontsize=extension_defaults.fontsize,
                    debug=False,
                ),
            ),
            text_closed="",
            background=extension_defaults.indigo,
            foreground=extension_defaults.white,
            fontsize=extension_defaults.widget_box_iconsize,
            start_opened=False,
        ),
        widget.TextBox(
            "",
            font=extension_defaults.font,
            fontsize=extension_defaults.endcap_fontsize,
            foreground=extension_defaults.indigo,
            padding=0,
        ),
    ]
)


top_widgets.extend(
    [
        widget.Spacer(length=10),
        widget.TextBox(
            "",
            font=extension_defaults.font,
            fontsize=extension_defaults.endcap_fontsize,
            foreground=extension_defaults.violet,
            padding=0,
        ),
        VolumeWidgetBox(
            widgets=(
                CustomVolume(
                    foreground=extension_defaults.white,
                    background=extension_defaults.violet,
                    font=extension_defaults.font,
                    fontsize=extension_defaults.fontsize,
                ),
            ),
            text_closed="󰓃",
            start_opened=False,
            background=extension_defaults.violet,
            foreground=extension_defaults.white,
            fontsize=extension_defaults.widget_box_iconsize,
        ),
        widget.TextBox(
            "",
            font=extension_defaults.font,
            fontsize=extension_defaults.endcap_fontsize,
            foreground=extension_defaults.violet,
            padding=0,
        ),
        widget.Spacer(length=10),
        widget.TextBox(
            "",
            font=extension_defaults.font,
            fontsize=extension_defaults.endcap_fontsize,
            foreground=extension_defaults.black,
            padding=0,
        ),
        StandardWidgetBox(
            widgets=(
                widget.Clock(
                    foreground=extension_defaults.foreground_yellow,
                    background=extension_defaults.black,
                    format="%a %b %d %H:%M:%S",
                    font=extension_defaults.font,
                    fontsize=extension_defaults.fontsize,
                ),
            ),
            text_closed="󰅐",
            start_opened=True,
            background=extension_defaults.black,
            foreground=extension_defaults.foreground_yellow,
            fontsize=extension_defaults.widget_box_iconsize,
        ),
        widget.TextBox(
            "",
            font=extension_defaults.font,
            fontsize=extension_defaults.endcap_fontsize,
            foreground=extension_defaults.black,
            padding=0,
        ),
        widget.Spacer(length=10),
        StandardWidgetBox(
            widgets=(
                widget.Systray(
                    icon_size=extension_defaults.iconsize,
                ),
            ),
            text_closed="󰒔",
            start_opened=True,
            foreground=extension_defaults.white,
            fontsize=extension_defaults.widget_box_iconsize,
        ),
    ]
)

SCREENS = [
    Screen(
        top=bar.Bar(
            top_widgets,
            extension_defaults.bar_thickness,
            margin=extension_defaults.bar_margin,
            border_width=0,
            background="#00000000",
        ),
        bottom=bar.Bar(
            [
                widget.Spacer(length=10),
                widget.TextBox(
                    "",
                    font=extension_defaults.font,
                    fontsize=extension_defaults.endcap_fontsize,
                    foreground=extension_defaults.black,
                    padding=0,
                ),
                StandardWidgetBox(
                    widgets=(
                        widget.GroupBox(
                            this_current_screen_border=extension_defaults.foreground,
                            this_screen_border=extension_defaults.inactive_foreground,
                            other_current_screen_border=extension_defaults.foreground,
                            other_screen_border=extension_defaults.inactive_foreground,
                            urgent_text=extension_defaults.foreground,
                            urgent_border=None,
                            background=extension_defaults.black,
                            font=extension_defaults.font,
                            fontsize=extension_defaults.fontsize,
                            use_mouse_wheel=False,
                            mouse_callbacks={"Button1": lambda: None},
                        ),
                        ScreenLayout(
                            # width=bar.STRETCH,
                            foreground=extension_defaults.foreground_yellow,
                            background=extension_defaults.black,
                            font=extension_defaults.font,
                            fontsize=extension_defaults.fontsize,
                        ),
                    ),
                    text_closed="",
                    start_opened=True,
                    background=extension_defaults.black,
                    foreground=extension_defaults.white,
                    fontsize=extension_defaults.widget_box_iconsize,
                ),
                widget.TextBox(
                    "",
                    font=extension_defaults.font,
                    fontsize=extension_defaults.endcap_fontsize,
                    foreground=extension_defaults.black,
                    padding=0,
                ),
                widget.Spacer(length=10),
                Snake(
                    name="Snake",
                    size=4,
                    mouse_callbacks={
                        "Button1": lambda: qtile.widgets_map.get("Snake").start(),
                        "Button3": lambda: qtile.widgets_map.get("Snake").stop(),
                    },
                    autostart=False,
                ),
                widget.Spacer(length=10),
                widget.TextBox(
                    "",
                    font=extension_defaults.font,
                    fontsize=extension_defaults.endcap_fontsize,
                    foreground=extension_defaults.violet,
                    padding=0,
                ),
                StandardWidgetBox(
                    widgets=(
                        Krill(
                            foreground=extension_defaults.white,
                            background=extension_defaults.violet,
                            update_interval=21,
                            font=extension_defaults.font,
                            fontsize=extension_defaults.fontsize,
                            debug=False,
                        ),
                    ),
                    text_closed="\uf1ea",
                    start_opened=True,
                    background=extension_defaults.violet,
                    foreground=extension_defaults.white,
                    fontsize=extension_defaults.widget_box_iconsize,
                ),
                widget.TextBox(
                    "",
                    font=extension_defaults.font,
                    fontsize=extension_defaults.endcap_fontsize,
                    foreground=extension_defaults.violet,
                    padding=0,
                ),
                widget.Spacer(length=10),
            ],
            extension_defaults.bar_thickness,
            margin=extension_defaults.bar_margin,
            border_width=0,
            background="#00000000",
        ),
    ),
]
