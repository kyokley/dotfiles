from dataclasses import dataclass


@dataclass
class ExtensionDefault:
    font: str = "Hack Nerd Font Mono"
    fontsize: int = 18
    iconsize: int = 30
    padding: int = 3
    foreground: str = "AE4CFF"
    background: str = None
    inactive_foreground: str = "404040"
    foreground_yellow: str = "FFDE3B"
    foreground_green: str = "00FF00"
    border_focus: str = "FF0000"
    border_normal: str = "030303"
    layout_margin: int = 40
    bar_margin: int = 10
    bar_thickness: int = 40


extension_defaults = ExtensionDefault()
