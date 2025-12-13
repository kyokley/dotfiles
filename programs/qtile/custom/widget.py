import json
import multiprocessing
import os
import random
import re
import shlex
import subprocess
import shutil

from dataclasses import dataclass
from datetime import datetime, timedelta
from enum import StrEnum
from pathlib import Path

import requests
from dateutil import tz
from libqtile.log_utils import logger
from libqtile.widget import (
    WidgetBox,
    Battery,
    Volume,
    TextBox,
    base,
    Net,
    DF,
    MemoryGraph,
    CPUGraph,
)
from libqtile.widget.battery import BatteryState
from libqtile.widget.generic_poll_text import GenPollText
from libqtile import qtile, hook

from custom.default import extension_defaults
from custom.utils import determine_browser

rand = random.SystemRandom()


class LogLevel(StrEnum):
    WARNING = "warning"
    EXCEPTION = "exception"


class DayOrNight(StrEnum):
    DAY = "day"
    NIGHT = "night"


KRILL_PROXY = os.environ.get("HTTP_PROXY", "")
REQUESTS_TIMEOUT = 30


BUTTON_UP = 4
BUTTON_DOWN = 5
BUTTON_LEFT = 1
BUTTON_MIDDLE = 2
BUTTON_RIGHT = 3

GCAL_CMD = (
    "docker run --rm "
    f"-v {str(Path.home())}/.gcalcli_oauth:/root/.gcalcli_oauth "
    "kyokley/gcalcli"
)
KRILL_CMD = f"docker run --rm -t --cpus=.25 --net=host --env KRILL_PROXY={KRILL_PROXY} kyokley/krill -S /app/sources.txt --snapshot"
TAILSCALE_CMD = "tailscale status"
TAILSCALE_TIMEOUT = 5
TAILSCALE_FAIL = b"Tailscale is stopped"

KRILL_BROWSER = determine_browser()
MAX_KRILL_LENGTH = 100

XAUTOLOCK_STATUS_PATH = Path("/tmp/xautolock.status")  # nosec


class DebugWidgetMixin:
    def _print(self, msg, level=LogLevel.WARNING):
        log_cmd = logger.warning if level == LogLevel.WARNING else logger.exception
        if self.debug:
            log_cmd("{}: {}".format(str(self.__class__), msg))


class DebugGenPollText(GenPollText, DebugWidgetMixin):
    defaults = [
        ("debug", False, "Enable additional debugging"),
    ]

    def __init__(self, **config):
        super().__init__(**config)
        self.add_defaults(DebugGenPollText.defaults)


class WallpaperDir(DebugGenPollText):
    defaults = [
        ("directory", "~/Pictures/wallpapers/", "Wallpaper Directory"),
        ("wallpaper_command", None, "Wallpaper command"),
        ("label", None, "Use a fixed label instead of image name."),
        ("all_images_label", "All", "Label to use for all images"),
        ("middle_click_command", None, "Command to run for middle-click"),
        ("update_interval", 600, "Update interval"),
    ]

    def __init__(self, **config):
        config["func"] = self.set_wallpaper
        super().__init__(**config)
        self.add_defaults(WallpaperDir.defaults)

        self._directories = dict()
        self._dir_index = 0
        self._image_index = 0
        self._cur_image = None

        self.text = "N/A"
        self.set_wallpaper()

    def _job(self):
        return self.set_wallpaper

    @staticmethod
    def _is_image(path):
        if path.is_file() and path.suffix.lower() in (".jpg", ".jpeg", ".png"):
            return True
        return False

    def get_wallpapers(self):
        self._directories = {self.all_images_label: []}
        for root, dirs, files in os.walk(self.directory):
            root_path = Path(root).resolve()

            for file in sorted(files):
                file_path = root_path / file
                if not self._is_image(file_path):
                    continue

                self._directories.setdefault(self.all_images_label, []).append(
                    file_path
                )

            for dir in sorted(dirs):
                dir_path = root_path / dir

                for file in sorted(os.listdir(dir_path)):
                    file_path = dir_path / file
                    if file_path.is_file() and self._is_image(file_path):
                        self._directories.setdefault(dir_path.name, []).append(
                            file_path
                        )
                        self._directories.setdefault(self.all_images_label, []).append(
                            file_path
                        )

    def set_wallpaper(self, use_random=True):
        self.get_wallpapers()
        try:
            directory = list(self._directories.keys())[self._dir_index]
        except IndexError:
            self._dir_index = 0
            directory = list(self._directories.keys())[self._dir_index]

        images = self._directories[directory]

        if not images:
            self.update("Empty")
            return

        try:
            if use_random:
                self._image_index = rand.randint(0, len(images) - 1)
            else:
                self._image_index = self._image_index % len(images)

            self._cur_image = images[self._image_index]
        except IndexError:
            self._image_index = 0
            self._cur_image = images[self._image_index]

        if self.label is None:
            cur_image_basename = Path(self._cur_image).name
            if not self.scroll:
                cur_image_basename = (
                    f"{cur_image_basename[:7]}..."
                    if len(cur_image_basename) > 7
                    else cur_image_basename
                )
            text = f"{directory}: {cur_image_basename}"
        else:
            text = self.label

        num_displays = int(
            subprocess.check_output(
                "xrandr | grep connected -w | wc -l", shell=True
            ).strip()
        )

        if self.wallpaper_command:
            self.wallpaper_command.append(self._cur_image)
            subprocess.call(self.wallpaper_command)
            self.wallpaper_command.pop()
        else:
            command = [
                "nitrogen",
                "--head=0",
                "--set-scaled",
                "--save",
                self._cur_image,
            ]
            subprocess.call(command)

            self._print(f"{num_displays=}")
            if num_displays > 1:
                for i in range(1, num_displays):
                    command = [
                        "nitrogen",
                        f"--head={i}",
                        "--random",
                        "--set-scaled",
                        "--save",
                        Path(self._cur_image).parent,
                    ]
                    subprocess.call(command)

        self._print(f"Update text to {text}")
        self.update(text)
        return text

    def button_press(self, x, y, button):
        self._print(button)
        if button == BUTTON_LEFT:
            self._image_index += 1
            self.set_wallpaper(use_random=False)
        elif button == BUTTON_RIGHT:
            self._image_index -= 1
            self.set_wallpaper(use_random=False)
        elif button == BUTTON_MIDDLE:
            if self.middle_click_command:
                command = shlex.split(self.middle_click_command)
                command.append(self._cur_image)
                subprocess.call(command)
            else:
                self.set_wallpaper(use_random=True)
        elif button == BUTTON_UP:
            self._dir_index += 1
            self.set_wallpaper(use_random=False)
        elif button == BUTTON_DOWN:
            self._dir_index -= 1
            self.set_wallpaper(use_random=False)


class CachedProxyRequest(DebugGenPollText):
    defaults = [
        ("http_proxy", None, "HTTP proxy to use for requests"),
        ("https_proxy", None, "HTTPS proxy to use for requests"),
        ("socks_proxy", None, "SOCKS proxy to use for requests"),
        ("cache_expiration", 5, "Length of time in minutes that cache is valid for"),
    ]

    def __init__(self, **config):
        super().__init__(**config)
        self.add_defaults(CachedProxyRequest.defaults)
        self._last_update = None
        self._cached_data = None
        self._locked = False

    def cached_fetch(self):
        if self._locked:
            self._print("Instance locked. Returning cached data")
            return self._cached_data

        try:
            self._print("Setting lock")
            self._locked = True
            if (
                not self._cached_data
                or not self._last_update
                or self._last_update + timedelta(minutes=self.cache_expiration)
                < datetime.now()
            ):
                self._print("Getting data")
                self._cached_data = self._fetch()
                self._print("Got:")
                self._print(self._cached_data)
                self._last_update = datetime.now()
        except Exception as e:
            self._print("Got error", level=LogLevel.EXCEPTION)
            self._print(str(e), level=LogLevel.EXCEPTION)
        finally:
            self._print("Releasing lock")
            self._locked = False
            return self._cached_data

    def _fetch(self):
        proxies = {
            "http": self.http_proxy,
            "https": self.https_proxy,
        }
        resp = requests.get(self.URL, proxies=proxies, timeout=REQUESTS_TIMEOUT)
        resp.raise_for_status()

        return resp.json()

    def clear_cache(self):
        self._last_update = None
        self._cached_data = None


@dataclass
class WeatherData:
    temp: float
    conditions: str


class Weather(CachedProxyRequest):
    URL = (
        "http://api.openweathermap.org/data/2.5/weather?"
        "id=4887398&units=imperial&appid=c4f4551816bd45b67708bea102d93522"
    )
    defaults = [
        ("low_temp_threshold", 45, "Temp to trigger low foreground"),
        ("high_temp_threshold", 80, "Temp to trigger high foreground"),
        ("low_foreground", "18BAEB", "Low foreground"),
        ("normal_foreground", "FFDE3B", "Normal foreground"),
        ("high_foreground", "FF000D", "High foreground"),
        ("markup", False, "Do not use pango markup"),
    ]

    def __init__(self, **config):
        config["func"] = self.get_weather
        super().__init__(**config)
        self.add_defaults(Weather.defaults)

    def get_weather(self):
        data = self.cached_fetch()
        if data:
            conditions = rand.choice(data["weather"])["description"]

            weather_data = WeatherData(data["main"]["temp"], conditions)

            if weather_data.temp > self.high_temp_threshold:
                self.layout.colour = self.high_foreground
            elif weather_data.temp < self.low_temp_threshold:
                self.layout.colour = self.low_foreground
            else:
                self.layout.colour = self.normal_foreground

            self._print(f"{self.layout.colour=}")
            self._print(
                f"Weather is {weather_data.temp:.2g}F {weather_data.conditions}"
            )

            weather_widget_box_icon = self.weather_icon(weather_data.conditions)
            weather_widget_box = qtile.widgets_map.get("WeatherWidgetBox")
            weather_widget_box.text = weather_widget_box.text_open = (
                weather_widget_box.text_closed
            ) = weather_widget_box_icon
            weather_widget_box.layout.colour = self.layout.colour
            weather_widget_box.bar.draw()

            return f"{weather_data.temp:.2g}F {weather_data.conditions}"
        return "N/A"

    def button_press(self, x, y, button):
        if button == BUTTON_LEFT:
            self.clear_cache()
            weather = self.get_weather()

            self.update(weather)

    @staticmethod
    def weather_icon(description: str) -> str:
        """
        Returns a Nerd Font weather icon for a given weather description.
        Includes day/night variants when possible.
        Icons use the Weather Icons (Nerd Font) set.
        """
        desc = description.lower().strip()

        # Detect time of day context
        now = datetime.now()
        if 6 < now.hour < 18:
            is_night = False
        else:
            is_night = True

        # Match descriptions to nf-md icons
        if any(word in desc for word in ["clear", "sunny", "bright"]):
            return (
                "󰖙" if not is_night else "󰖔"
            )  # nf-md-weather_sunny / nf-md-weather_night
        elif any(word in desc for word in ["partly", "cloud", "overcast"]):
            if is_night:
                return "󰼱"  # nf-md-weather_night_partly_cloudy
            else:
                return "󰖕"  # nf-md-weather_partly_cloudy
        elif any(word in desc for word in ["rain", "drizzle", "shower"]):
            return "󰖖"  # nf-md-weather_rainy
        elif any(word in desc for word in ["thunder", "storm", "lightning"]):
            return "󰙾"  # nf-md-weather_lightning_rainy
        elif any(word in desc for word in ["snow", "sleet", "blizzard", "hail"]):
            if is_night:
                return "󰖘"  # nf-md-weather_snowy
            else:
                return "󰼴"  # nf-md-weather_night_snowy
        elif any(word in desc for word in ["fog", "mist", "haze", "smog", "smoke"]):
            return "󰖑"  # nf-md-weather_fog
        elif any(word in desc for word in ["wind", "breeze", "gust"]):
            return "󰖝"  # nf-md-weather_windy
        elif any(word in desc for word in ["tornado", "hurricane", "cyclone"]):
            return "󰼸"  # nf-md-weather_tornado
        else:
            return ""  # nf-md-weather_unknown


class GCal(CachedProxyRequest):
    DATE_FORMAT = "%a %b %d %H:%M:%S %Z %Y"
    SPACE_REGEX = re.compile(b"\s+")  # noqa

    defaults = [
        ("default_foreground", "FFDE3B", "Default foreground color"),
        ("soon_foreground", "FF000D", "Color used for events occuring soon"),
        ("markup", False, "Do not use pango markup"),
    ]

    def __init__(self, **config):
        config["func"] = self.get_cal
        super().__init__(**config)
        self.add_defaults(GCal.defaults)
        self._current_item = None
        self.layout.colour = self.default_foreground

    def get_cal(self):
        self._data = self.cached_fetch()

        if not self._data:
            return "No Events"

        self._current_item = rand.choice(self._data)
        if self._current_item[0]:
            self.layout.colour = self.soon_foreground
        else:
            self.layout.colour = self.default_foreground

        return self._format_line(self._current_item[1])

    def _format_line(self, line):
        line = line.decode("utf-8").split()
        return "{event} ({date})".format(
            event=" ".join(line[3:]), date=" ".join(line[:3])
        )

    def _fetch(self):
        now = datetime.now(tz=tz.gettz("America/Chicago"))
        past_dt = now - timedelta(hours=1)
        short_dt = now + timedelta(hours=1)
        future_dt = now + timedelta(hours=120)

        short_cmd = shlex.split(GCAL_CMD)
        if self.https_proxy:
            short_cmd.extend(["--proxy", self.https_proxy])

        short_cmd.extend(
            [
                "--nocolor",
                "agenda",
                past_dt.strftime(GCal.DATE_FORMAT),
                short_dt.strftime(GCal.DATE_FORMAT),
            ]
        )

        proc = subprocess.check_output(short_cmd)

        if proc:
            lines = [
                (True, GCal.SPACE_REGEX.sub(b" ", x))
                for x in proc.splitlines()
                if x and not x.startswith(b"No Events Found")
            ]

        long_cmd = shlex.split(GCAL_CMD)
        if self.https_proxy:
            long_cmd.extend(["--proxy", self.https_proxy])

        long_cmd.extend(
            [
                "--nocolor",
                "agenda",
                short_dt.strftime(GCal.DATE_FORMAT),
                future_dt.strftime(GCal.DATE_FORMAT),
            ]
        )

        proc = subprocess.check_output(long_cmd)

        if proc:
            lines.extend(
                [
                    (False, GCal.SPACE_REGEX.sub(b" ", x))
                    for x in proc.splitlines()
                    if x
                    and GCal.SPACE_REGEX.sub(b" ", x) not in map(lambda x: x[1], lines)
                ]
            )
        return lines

    def button_press(self, x, y, button):
        if button == BUTTON_LEFT:
            self.get_cal()
        elif button == BUTTON_RIGHT:
            self.clear_cache()
        elif button in (BUTTON_UP, BUTTON_DOWN):
            if self._data:
                if button == BUTTON_UP:
                    idx = self._data.index(self._current_item) + 1
                else:
                    idx = self._data.index(self._current_item) - 1
                self._current_item = self._data[idx % len(self._data)]
                self._last_update = datetime.now() + timedelta(
                    seconds=self.update_interval
                )
            else:
                return

        self.layout.colour = (
            self.soon_foreground if self._current_item[0] else self.default_foreground
        )
        self.update(self._format_line(self._current_item[1]))


class Krill(CachedProxyRequest):
    defaults = [
        ("markup", False, "Do not use pango markup"),
    ]

    def __init__(self, **config):
        config["func"] = self.get_krill
        super().__init__(**config)
        self.add_defaults(Krill.defaults)
        self._current_item = None
        self._last_item_change_time = None

    def get_krill(self):
        self._data = self.cached_fetch()
        self._data = [x for x in self._data if "title" in x]

        if not self._data:
            return "Could not load data from sources"

        if (
            not self._last_item_change_time
            or self._last_item_change_time + timedelta(seconds=self.update_interval)
            < datetime.now()
        ):
            self._current_item = rand.choice(self._data)
            self._last_item_change_time = datetime.now()
        return (
            self._current_item["title"]
            if isinstance(self._current_item, dict)
            else self._current_item
        )

    def _fetch(self):
        cmd = shlex.split(KRILL_CMD)
        proc = subprocess.check_output(cmd)
        data = []

        if proc:
            for raw_item in proc.splitlines():
                item = raw_item.decode("utf-8").strip()
                self._print(item)
                if not item:
                    continue

                try:
                    item_data = json.loads(item)
                    if item_data:
                        data.append(item_data)
                except Exception as e:
                    self._print(item)
                    self._print(e, level=LogLevel.EXCEPTION)

            if data:
                return data

        return ["Failed to load"]

    def button_press(self, x, y, button):
        if button == BUTTON_LEFT:
            if self._current_item and self._current_item.get("link"):
                self.qtile.spawn(f"{KRILL_BROWSER} {self._current_item['link']}")
        elif button in (BUTTON_UP, BUTTON_DOWN):
            if self._data:
                if button == BUTTON_UP:
                    idx = self._data.index(self._current_item) + 1
                else:
                    idx = self._data.index(self._current_item) - 1
                self._current_item = self._data[idx % len(self._data)]
                self.update(self._current_item["title"])
                self._last_item_change_time = datetime.now() + timedelta(
                    seconds=self.update_interval
                )

    def update(self, text):
        if len(text) > MAX_KRILL_LENGTH:
            truncated_text = f"{text[:MAX_KRILL_LENGTH]}..."
        else:
            truncated_text = text

        super().update(truncated_text)


class MaxCPUGraph(CPUGraph):
    def __init__(self, **config):
        self._num_cores = multiprocessing.cpu_count()
        CPUGraph.__init__(self, **config)
        self.oldvalues = self._getvalues()

    def _getvalues(self):
        proc = "/proc/stat"

        with open(proc) as file:
            file.readline()
            lines = file.readlines()

        vals = [line.split(None, 6)[1:5] for line in lines[: self._num_cores]]
        return [map(int, val) for val in vals]

    def update_graph(self):
        new_values = self._getvalues()
        old_values = self.oldvalues

        max_percent = 0
        for old, new in zip(old_values, new_values):
            try:
                old_user, new_user = next(old), next(new)
                old_nice, new_nice = next(old), next(new)
                old_sys, new_sys = next(old), next(new)
                old_idle, new_idle = next(old), next(new)
            except StopIteration:
                continue

            busy = new_user + new_nice + new_sys - old_user - old_nice - old_sys
            total = busy + new_idle - old_idle

            if total:
                percent = float(busy) / total * 100
            else:
                percent = 0

            max_percent = max(max_percent, percent)

        self.oldvalues = new_values

        if max_percent:
            self.push(max_percent)


class StandardWidgetBox(WidgetBox):
    def __init__(
        self,
        font=extension_defaults.font,
        fontsize=extension_defaults.fontsize,
        foreground=extension_defaults.foreground_green,
        text_closed=None,
        start_opened=True,
        **kwargs,
    ):
        super().__init__(**kwargs)
        self.font = font
        self.fontsize = fontsize
        self.foreground = foreground
        self.text_closed = text_closed
        self.start_opened = start_opened

        if "text_open" not in kwargs:
            self.text_open = f"{text_closed}" if text_closed is not None else None


class TailscaleNetWidgetBox(StandardWidgetBox):
    def __init__(self, start_opened=False, **kwargs):
        kwargs["name"] = "TailscaleNetWidgetBox"
        super().__init__(start_opened=start_opened, **kwargs)
        self.default_foreground = self.foreground


class TailscaleNet(Net, DebugWidgetMixin):
    def poll(self):
        if tailscale_net_widget_box := qtile.widgets_map.get("TailscaleNetWidgetBox"):
            if self._check_tailscale():
                tailscale_net_widget_box.layout.colour = (
                    tailscale_net_widget_box.default_foreground
                )
            else:
                tailscale_net_widget_box.layout.colour = extension_defaults.red
            tailscale_net_widget_box.bar.draw()

        return super().poll()

    def _check_tailscale(self):
        if shutil.which("tailscale"):
            cmd = shlex.split(TAILSCALE_CMD)

            try:
                proc = subprocess.run(
                    cmd, check=True, capture_output=True, timeout=TAILSCALE_TIMEOUT
                )
                self._print(f"{proc=}")

                if TAILSCALE_FAIL in proc.stdout:
                    return False
                return True
            except (subprocess.CalledProcessError, FileNotFoundError) as e:
                self._print(f"{e=}")
                return False
        return True


class DFWidgetBox(StandardWidgetBox):
    def __init__(self, start_opened=False, **kwargs):
        kwargs["name"] = "DFWidgetBox"
        super().__init__(start_opened=start_opened, **kwargs)


class CustomDF(DF, DebugWidgetMixin):
    def poll(self):
        ret_val = super().poll()

        if df_widget_box := qtile.widgets_map.get("DFWidgetBox"):
            if self.user_free <= self.warn_space:
                df_widget_box.layout.colour = extension_defaults.red
            else:
                df_widget_box.layout.colour = extension_defaults.black
            df_widget_box.bar.draw()

        return ret_val


class WeatherWidgetBox(StandardWidgetBox):
    def __init__(self, start_opened=False, **kwargs):
        kwargs["name"] = "WeatherWidgetBox"
        super().__init__(start_opened=start_opened, **kwargs)


class BatteryWidgetBox(StandardWidgetBox):
    def __init__(self, start_opened=False, **kwargs):
        kwargs["name"] = "BatteryWidgetBox"
        super().__init__(start_opened=start_opened, **kwargs)


class VolumeWidgetBox(StandardWidgetBox):
    def __init__(self, start_opened=False, **kwargs):
        kwargs["name"] = "VolumeWidgetBox"
        super().__init__(start_opened=start_opened, **kwargs)


class CustomVolume(Volume):
    def update(self):
        volume_widget_box_icon = self.parent_widget()
        volume_widget_box = qtile.widgets_map.get("VolumeWidgetBox")
        volume_widget_box.text = volume_widget_box.text_open = (
            volume_widget_box.text_closed
        ) = volume_widget_box_icon
        super().update()

    def parent_widget(self):
        """
        Return a Nerd Font (nf-md) icon name representing the given volume percentage.

        Args:
            percent: volume percentage (expected 0..100). Values outside the range are clamped.

        Returns:
            A string with an nf-md icon name. Example outputs:
                'nf-md-volume-off', 'nf-md-volume-mute', 'nf-md-volume-low',
                'nf-md-volume-medium', 'nf-md-volume-high'
            If you're not using a matching Nerd Font set, the function falls back to an emoji label.
        """
        # clamp input to 0..100 and ensure int
        vol, muted = self.get_volume()
        p = max(0, min(100, int(vol)))

        # exact zero -> fully off
        if muted or p == 0:
            return "󰖁"  # silent / muted

        # very low volumes
        if p < 10:
            return "󰕿"

        # low but audible
        if p < 40:
            return "󰖀"

        # loud
        return "󰕾"


class CustomBattery(Battery):
    def poll(self):
        return_val = super().poll()
        self.set_parent_widget()
        return return_val

    def set_parent_widget(self):
        try:
            status = self._battery.update_status()
        except RuntimeError as e:
            return f"Error: {e}"

        charging = status.state == BatteryState.CHARGING
        icon = self.battery_icon(status.percent, charging)

        battery_widget_box = qtile.widgets_map.get("BatteryWidgetBox")
        battery_widget_box.text = battery_widget_box.text_closed = (
            battery_widget_box.text_open
        ) = icon
        battery_widget_box.layout.colour = self.layout.colour
        battery_widget_box.bar.draw()

    def battery_icon(self, percent, charging: bool = False) -> str:
        """
        Return an nf-md (Nerd Font - Material Design) icon name representing battery level.

        Args:
            percent: battery percentage (0-100). If None or out of range, returns unknown icon.
            charging: if True, prefers charging icon variants when available.

        Returns:
            A string containing an nf-md icon name that you can use in statusbars/terminals
            (e.g. "nf-md-battery-80" or "nf-md-battery-charging").
        """

        # Handle explicit unknown / invalid
        if percent is None or percent < 0:
            return "󰂑"  # nf-md-battery_unknown

        percent *= 100

        # Clamp to 0..100
        percent = max(0, min(100, percent))

        # Map ranges to common Material Design battery icons
        if percent <= 15:
            if charging:
                return "󰢜"  # nf-md-battery_charging_10
            return "󱃍"  # nf-md-battery_alert_variant_outline
        if percent <= 25:
            if charging:
                return "󰂆"
            return "󰁻"
        if percent <= 35:
            if charging:
                return "󰂇"
            return "󰁼"
        if percent <= 45:
            if charging:
                return "󰂈"
            return "󰁽"
        if percent <= 55:
            if charging:
                return "󰢝"
            return "󰁾"
        if percent <= 65:
            if charging:
                return "󰂉"
            return "󰁿"
        if percent <= 75:
            if charging:
                return "󰢞"
            return "󰂀"
        if percent <= 85:
            if charging:
                return "󰂊"
            return "󰂁"
        if percent <= 95:
            if charging:
                return "󰂋"
            return "󰂂"
        else:
            if charging:
                return "󰂅"
            return "󰁹"  # full/near-full icon


class CustomWindowNameEndcap(TextBox):
    defaults = [
        (
            "for_current_screen",
            False,
            "instead of this bars screen use currently active screen",
        ),
    ]

    def __init__(self, text=" ", **kwargs):
        super().__init__(text=text, **kwargs)
        self.add_defaults(CustomWindowNameEndcap.defaults)

        self._original_text = text

    def _configure(self, qtile, bar):
        super()._configure(qtile, bar)
        hook.subscribe.client_name_updated(self.hook_response)
        hook.subscribe.focus_change(self.hook_response)
        hook.subscribe.float_change(self.hook_response)
        hook.subscribe.current_screen_change(self.hook_response_current_screen)

    def remove_hooks(self):
        hook.unsubscribe.client_name_updated(self.hook_response)
        hook.unsubscribe.focus_change(self.hook_response)
        hook.unsubscribe.float_change(self.hook_response)
        hook.unsubscribe.current_screen_change(self.hook_response_current_screen)

    def hook_response(self, *args):
        if self.for_current_screen:
            w = self.qtile.current_screen.group.current_window
        else:
            w = self.bar.screen.group.current_window

        if not w:
            self.update(" ")
        else:
            self.update(self._original_text)

    def hook_response_current_screen(self, *args):
        if self.for_current_screen:
            self.hook_response()

    def finalize(self):
        self.remove_hooks()
        base._TextBox.finalize(self)


class MemoryGraphWidgetBox(StandardWidgetBox):
    def __init__(self, start_opened=False, **kwargs):
        kwargs["name"] = "MemoryGraphWidgetBox"
        super().__init__(start_opened=start_opened, **kwargs)
        self.default_foreground = extension_defaults.black


class CustomMemoryGraph(MemoryGraph):
    defaults = [
        (
            "warning_threshold",
            80,
            "Percentage threshold for displaying warning icon",
        ),
    ]

    def __init__(self, **config):
        super().__init__(**config)
        self.add_defaults(CustomMemoryGraph.defaults)
        self.default_foreground = extension_defaults.black

    def _mem_used_percent(self):
        val = self._getvalues()
        used = val["MemTotal"] - val["MemFree"] - val["Buffers"] - val["Cached"]
        percent = 100 * (used / val["MemTotal"])
        return percent

    def update_graph(self):
        super().update_graph()

        if memory_graph_widget := qtile.widgets_map.get("MemoryGraphWidgetBox"):
            percent = self._mem_used_percent()
            if percent > self.warning_threshold:
                memory_graph_widget.layout.colour = extension_defaults.red
            else:
                memory_graph_widget.layout.colour = (
                    memory_graph_widget.default_foreground
                )
            memory_graph_widget.bar.draw()


class CPUGraphWidgetBox(StandardWidgetBox):
    def __init__(self, start_opened=False, **kwargs):
        kwargs["name"] = "CPUGraphWidgetBox"
        super().__init__(start_opened=start_opened, **kwargs)
        self.default_foreground = extension_defaults.black


class CustomCPUGraph(CPUGraph):
    defaults = [
        (
            "warning_threshold",
            80,
            "Percentage threshold for displaying warning icon",
        ),
    ]

    def __init__(self, **config):
        super().__init__(**config)
        self.add_defaults(CustomMemoryGraph.defaults)
        self.default_foreground = extension_defaults.black

    def update_graph(self):
        super().update_graph()

        if cpu_graph_widget := qtile.widgets_map.get("CPUGraphWidgetBox"):
            percent = self.values[0]
            if percent > self.warning_threshold:
                cpu_graph_widget.layout.colour = extension_defaults.red
            else:
                cpu_graph_widget.layout.colour = cpu_graph_widget.default_foreground
            cpu_graph_widget.bar.draw()
