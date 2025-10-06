from dataclasses import dataclass


@dataclass
class ExtensionDefault:
    font: str = "Hack Nerd Font Mono"
    fontsize: int = 18
    endcap_fontsize: int = 30
    iconsize: int = 30
    padding: int = 3
    foreground: str = "AE4CFF"
    background: str = None
    inactive_foreground: str = "404040"
    border_focus: str = "FF0000"
    border_normal: str = "030303"
    layout_margin: int = 40
    bar_margin: int = 10
    bar_thickness: int = 40
    red: str = "#FF0000"
    orange: str = "#FF7F00"
    yellow: str = "#FFFF00"
    green: str = "#00FF00"
    blue: str = "#0000FF"
    indigo: str = "#4B0082"
    violet: str = "#9400D3"
    white: str = "#FFFFFF"
    black: str = "#000000"

    foreground_yellow: str = "FFDE3B"
    foreground_green: str = "00FF00"


extension_defaults = ExtensionDefault()
