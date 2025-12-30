from dataclasses import dataclass


@dataclass
class ExtensionDefault:
    font: str = "Hack Nerd Font Mono"
    fontsize: int = 18
    endcap_fontsize: int = 40
    iconsize: int = 30
    widget_box_iconsize: int = 40
    padding: int = 3
    foreground: str = "AE4CFF"
    background: str = None
    inactive_foreground: str = "#404040"
    border_focus: str = "#FF0000"
    border_normal: str = "#030303"
    layout_margin: int = 30
    bar_margin: int = 10
    bar_thickness: int = 40
    bar_border_width: int = 5
    red: str = "#FF0000"
    orange: str = "#FFBF00"
    yellow: str = "#FFFF00"
    green: str = "#00FF00"
    cyan: str = "#00FFFF"
    blue: str = "#0000FF"
    indigo: str = "#4B0082"
    violet: str = "#9400D3"
    white: str = "#FFFFFF"
    black: str = "#000000"

    foreground_yellow: str = "FFDE3B"
    foreground_green: str = "00FF00"


extension_defaults = ExtensionDefault()
