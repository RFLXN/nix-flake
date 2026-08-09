from __future__ import annotations

import argparse
import fcntl
import json
import os
import re
import signal
import subprocess
import sys
import time
from pathlib import Path
from typing import Any


class ProfileError(RuntimeError):
    pass


class ProfileManager:
    def __init__(self, config_path: str) -> None:
        with open(config_path, encoding="utf-8") as config_file:
            self.config = json.load(config_file)

        self.profiles = {
            profile["name"]: profile for profile in self.config["profiles"]
        }
        self.default_profile = self.config["defaultProfile"]
        self.tools = self.config["tools"]

        state_home = os.environ.get("XDG_STATE_HOME")
        if not state_home:
            state_home = os.path.join(Path.home(), ".local", "state")
        runtime_dir = os.environ.get("XDG_RUNTIME_DIR")
        if not runtime_dir:
            runtime_dir = f"/run/user/{os.getuid()}"

        self.state_dir = Path(state_home) / "pipewire-profile-changer"
        self.state_file = self.state_dir / "active-profile"
        self.lock_file = Path(runtime_dir) / "pipewire-profile-changer.lock"

    def profile(self, name: str) -> dict[str, Any]:
        try:
            return self.profiles[name]
        except KeyError as error:
            available = ", ".join(self.profiles)
            raise ProfileError(
                f"Unknown profile {name!r}; available profiles: {available}"
            ) from error

    def current_name(self) -> str:
        try:
            name = self.state_file.read_text(encoding="utf-8").strip()
        except FileNotFoundError:
            return self.default_profile
        return name if name in self.profiles else self.default_profile

    def _write_current(self, name: str) -> None:
        self.state_dir.mkdir(mode=0o700, parents=True, exist_ok=True)
        temporary = self.state_file.with_suffix(".tmp")
        temporary.write_text(f"{name}\n", encoding="utf-8")
        temporary.chmod(0o600)
        os.replace(temporary, self.state_file)

    def _run(
        self,
        command: list[str],
        *,
        check: bool = True,
    ) -> subprocess.CompletedProcess[str]:
        try:
            result = subprocess.run(
                command,
                check=False,
                capture_output=True,
                text=True,
            )
        except OSError as error:
            raise ProfileError(f"Could not run {command[0]}: {error}") from error

        if check and result.returncode != 0:
            detail = result.stderr.strip() or result.stdout.strip() or "unknown error"
            raise ProfileError(f"{' '.join(command)} failed: {detail}")
        return result

    def _with_lock(self):
        self.lock_file.parent.mkdir(mode=0o700, parents=True, exist_ok=True)
        lock = self.lock_file.open("a+", encoding="utf-8")
        fcntl.flock(lock.fileno(), fcntl.LOCK_EX)
        return lock

    def _metadata_value(self, key: str) -> int | None:
        result = self._run([self.tools["pwMetadata"], "-n", "settings", "0", key])
        match = re.search(rf"key:'{re.escape(key)}' value:'([^']+)'", result.stdout)
        if not match:
            return None
        try:
            return int(match.group(1))
        except ValueError:
            return None

    def _set_metadata(self, key: str, value: int) -> None:
        self._run(
            [
                self.tools["pwMetadata"],
                "-n",
                "settings",
                "0",
                key,
                str(value),
            ]
        )

    def _ensure_clock(self, profile: dict[str, Any]) -> None:
        values = {
            "clock.force-rate": profile["rate"] or 0,
            "clock.force-quantum": profile["quantum"] or 0,
        }
        for key, value in values.items():
            if self._metadata_value(key) != value:
                self._set_metadata(key, value)

    def _pipewire_dump(self) -> list[dict[str, Any]]:
        result = self._run([self.tools["pwDump"]])
        try:
            value = json.loads(result.stdout)
        except json.JSONDecodeError as error:
            raise ProfileError(f"Could not parse pw-dump output: {error}") from error
        if not isinstance(value, list):
            raise ProfileError("pw-dump returned an unexpected value")
        return value

    @staticmethod
    def _find_device(
        dump: list[dict[str, Any]], device_name: str
    ) -> dict[str, Any] | None:
        for item in dump:
            if item.get("type") != "PipeWire:Interface:Device":
                continue
            props = item.get("info", {}).get("props", {})
            if props.get("device.name") == device_name:
                return item
        return None

    @staticmethod
    def _active_device_profile(device: dict[str, Any]) -> str | None:
        profiles = device.get("info", {}).get("params", {}).get("Profile", [])
        if not profiles:
            return None
        return profiles[0].get("name")

    @staticmethod
    def _device_profile_index(device: dict[str, Any], profile_name: str) -> int:
        profiles = device.get("info", {}).get("params", {}).get("EnumProfile", [])
        for profile in profiles:
            if profile.get("name") == profile_name:
                return int(profile["index"])
        available = ", ".join(str(profile.get("name", "?")) for profile in profiles)
        raise ProfileError(
            f"Device {device['id']} has no profile {profile_name!r}; "
            f"available profiles: {available or 'none'}"
        )

    def _ensure_device_profile(
        self,
        setting: dict[str, Any],
        *,
        dump: list[dict[str, Any]],
    ) -> None:
        device = self._find_device(dump, setting["device"])
        if device is None:
            if setting["required"]:
                raise ProfileError(f"PipeWire device not found: {setting['device']}")
            return

        desired_profile = setting["profile"]
        if self._active_device_profile(device) == desired_profile:
            return

        index = self._device_profile_index(device, desired_profile)
        self._run([self.tools["wpctl"], "set-profile", str(device["id"]), str(index)])

        deadline = time.monotonic() + 3
        while time.monotonic() < deadline:
            current = self._find_device(self._pipewire_dump(), setting["device"])
            if (
                current is not None
                and self._active_device_profile(current) == desired_profile
            ):
                return
            time.sleep(0.1)
        raise ProfileError(
            f"Timed out while setting {setting['device']} to {desired_profile}"
        )

    def _service_is_active(self, service: str) -> bool:
        result = self._run(
            [self.tools["systemctl"], "--user", "is-active", "--quiet", service],
            check=False,
        )
        return result.returncode == 0

    def _ensure_services(
        self, profile: dict[str, Any], *, before_devices: bool
    ) -> None:
        if before_devices:
            for service in profile["stopUserServices"]:
                if self._service_is_active(service):
                    self._run([self.tools["systemctl"], "--user", "stop", service])
        else:
            for service in profile["startUserServices"]:
                if not self._service_is_active(service):
                    self._run([self.tools["systemctl"], "--user", "start", service])

    def _apply(self, profile: dict[str, Any]) -> None:
        self._ensure_services(profile, before_devices=True)
        self._ensure_clock(profile)
        if profile["deviceProfiles"]:
            dump = self._pipewire_dump()
            for setting in profile["deviceProfiles"]:
                self._ensure_device_profile(setting, dump=dump)
                dump = self._pipewire_dump()
        self._ensure_services(profile, before_devices=False)

    def apply(self, name: str, *, notify: bool = True) -> None:
        target = self.profile(name)
        lock = self._with_lock()
        try:
            previous_name = self.current_name()
            try:
                self._apply(target)
            except ProfileError:
                if previous_name != name and previous_name in self.profiles:
                    try:
                        self._apply(self.profiles[previous_name])
                    except ProfileError as rollback_error:
                        print(
                            f"Profile rollback failed: {rollback_error}",
                            file=sys.stderr,
                        )
                raise
            self._write_current(name)
        finally:
            lock.close()

        if notify:
            self.notify_profile(target)

    def apply_current_with_retry(self, attempts: int = 20) -> None:
        last_error: ProfileError | None = None
        for attempt in range(attempts):
            try:
                self.apply(self.current_name(), notify=False)
                return
            except ProfileError as error:
                last_error = error
                if attempt + 1 < attempts:
                    time.sleep(0.5)
        if last_error is not None:
            raise last_error

    def ensure_current(self) -> None:
        lock = self._with_lock()
        try:
            self._apply(self.profile(self.current_name()))
        finally:
            lock.close()

    def _notify(self, icon: str, summary: str, body: str, urgency: str) -> None:
        subprocess.Popen(
            [
                self.tools["notifySend"],
                "--app-name=PipeWire Profile Changer",
                f"--icon={icon}",
                f"--urgency={urgency}",
                summary,
                body,
            ],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
        )

    def notify_profile(self, profile: dict[str, Any]) -> None:
        self._notify(
            profile["icon"],
            f"Audio profile: {profile['label']}",
            profile["description"],
            "normal",
        )

    def notify_error(self, error: Exception) -> None:
        self._notify(
            "dialog-error",
            "Audio profile switch failed",
            str(error),
            "critical",
        )


def check_tray_dependencies() -> None:
    import gi

    gi.require_version("Gtk", "3.0")
    gi.require_version("GLibUnix", "2.0")
    gi.require_version("AyatanaAppIndicator3", "0.1")
    from gi.repository import AyatanaAppIndicator3, GLibUnix, Gtk  # noqa: F401


def run_tray(manager: ProfileManager) -> int:
    import gi

    gi.require_version("Gtk", "3.0")
    gi.require_version("GLibUnix", "2.0")
    gi.require_version("AyatanaAppIndicator3", "0.1")
    from gi.repository import AyatanaAppIndicator3, GLib, GLibUnix, Gtk

    class ProfileTray:
        def __init__(self) -> None:
            self.updating = True
            self.last_error: str | None = None
            self.items: dict[str, Any] = {}
            initial = manager.profile(manager.current_name())
            self.indicator = AyatanaAppIndicator3.Indicator.new(
                "pipewire-profile-changer",
                initial["icon"],
                AyatanaAppIndicator3.IndicatorCategory.HARDWARE,
            )
            self.indicator.set_status(AyatanaAppIndicator3.IndicatorStatus.ACTIVE)

            menu = Gtk.Menu()
            heading = Gtk.MenuItem(label="PipeWire audio profile")
            heading.set_sensitive(False)
            menu.append(heading)
            menu.append(Gtk.SeparatorMenuItem())

            group = None
            for profile in manager.config["profiles"]:
                item = Gtk.RadioMenuItem.new_with_label(group, profile["label"])
                if group is None:
                    group = item.get_group()
                item.connect("toggled", self._on_toggled, profile["name"])
                menu.append(item)
                self.items[profile["name"]] = item

            menu.append(Gtk.SeparatorMenuItem())
            reapply = Gtk.MenuItem(label="Reapply current profile")
            reapply.connect("activate", self._on_reapply)
            menu.append(reapply)
            menu.show_all()
            self.indicator.set_menu(menu)

            self._show_profile(initial)
            self.updating = False
            GLib.timeout_add_seconds(
                int(manager.config["pollIntervalSeconds"]), self._poll
            )

        def _show_profile(self, profile: dict[str, Any]) -> None:
            self.updating = True
            self.last_error = None
            self.items[profile["name"]].set_active(True)
            self.indicator.set_icon_full(profile["icon"], profile["label"])
            self.indicator.set_title(f"Audio profile: {profile['label']}")
            self.indicator.set_status(AyatanaAppIndicator3.IndicatorStatus.ACTIVE)
            self.updating = False

        def _show_error(self, error: Exception) -> None:
            message = str(error)
            print(f"PipeWire profile error: {message}", file=sys.stderr)
            self.indicator.set_icon_full("dialog-warning", message)
            self.indicator.set_title(f"Audio profile error: {message}")
            self.indicator.set_status(AyatanaAppIndicator3.IndicatorStatus.ATTENTION)
            if message != self.last_error:
                manager.notify_error(error)
            self.last_error = message

        def _on_toggled(self, item: Any, name: str) -> None:
            if self.updating or not item.get_active():
                return
            try:
                manager.apply(name)
                self._show_profile(manager.profile(name))
            except ProfileError as error:
                self._show_error(error)
                self._show_profile(manager.profile(manager.current_name()))

        def _on_reapply(self, _item: Any) -> None:
            try:
                name = manager.current_name()
                manager.apply(name)
                self._show_profile(manager.profile(name))
            except ProfileError as error:
                self._show_error(error)

        def _poll(self) -> bool:
            try:
                manager.ensure_current()
                self._show_profile(manager.profile(manager.current_name()))
            except ProfileError as error:
                self._show_error(error)
            return True

    tray = ProfileTray()

    def quit_main() -> bool:
        Gtk.main_quit()
        return False

    GLibUnix.signal_add(GLib.PRIORITY_DEFAULT, signal.SIGTERM, quit_main)
    GLibUnix.signal_add(GLib.PRIORITY_DEFAULT, signal.SIGINT, quit_main)
    Gtk.main()
    del tray
    return 0


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Switch declarative PipeWire profiles")
    parser.add_argument("--config", required=True)
    commands = parser.add_subparsers(dest="command", required=True)
    set_command = commands.add_parser("set", help="activate a profile")
    set_command.add_argument("profile")
    commands.add_parser("current", help="print the active profile name")
    commands.add_parser("list", help="list configured profiles")
    commands.add_parser("apply", help="reapply the active profile")
    commands.add_parser("tray", help="run the system tray service")
    commands.add_parser("check-tray", help="validate tray library imports")
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    manager = ProfileManager(args.config)
    try:
        if args.command == "set":
            manager.apply(args.profile)
        elif args.command == "current":
            print(manager.current_name())
        elif args.command == "list":
            current = manager.current_name()
            for profile in manager.config["profiles"]:
                marker = "*" if profile["name"] == current else " "
                print(f"{marker} {profile['name']}\t{profile['label']}")
        elif args.command == "apply":
            manager.apply_current_with_retry()
        elif args.command == "tray":
            manager.apply_current_with_retry()
            return run_tray(manager)
        elif args.command == "check-tray":
            check_tray_dependencies()
            print("tray dependencies are available")
    except ProfileError as error:
        print(f"pipewire-profile: {error}", file=sys.stderr)
        manager.notify_error(error)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
