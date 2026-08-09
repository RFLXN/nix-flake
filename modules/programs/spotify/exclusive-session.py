from __future__ import annotations

import argparse
import fcntl
import json
import os
import shutil
import signal
import subprocess
import sys
import time
from dataclasses import dataclass
from pathlib import Path
from typing import Any


class SessionError(RuntimeError):
    pass


@dataclass(frozen=True, order=True)
class LinkPorts:
    output_port: int
    input_port: int


@dataclass(frozen=True)
class GraphLink:
    link_id: int
    ports: LinkPorts
    output_node: int
    input_node: int


@dataclass(frozen=True)
class PulseSinkInput:
    index: int
    sink: int
    properties: dict[str, Any]

    @property
    def is_spotify_exclusive(self) -> bool:
        return self.properties.get("spotify.exclusive") == "enabled"


def run(
    command: list[str],
    *,
    check: bool = True,
    timeout: float | None = 5,
) -> subprocess.CompletedProcess[str]:
    try:
        result = subprocess.run(
            command,
            check=False,
            capture_output=True,
            text=True,
            timeout=timeout,
        )
    except (OSError, subprocess.TimeoutExpired) as error:
        raise SessionError(f"Could not run {command[0]}: {error}") from error

    if check and result.returncode != 0:
        detail = result.stderr.strip() or result.stdout.strip() or "unknown error"
        raise SessionError(f"{' '.join(command)} failed: {detail}")
    return result


def parse_json_output(result: subprocess.CompletedProcess[str], source: str) -> Any:
    try:
        return json.loads(result.stdout)
    except json.JSONDecodeError as error:
        raise SessionError(f"Could not parse {source} output: {error}") from error


def pipewire_dump(pw_dump: str) -> list[dict[str, Any]]:
    graph = parse_json_output(run([pw_dump]), "pw-dump")
    if not isinstance(graph, list):
        raise SessionError("pw-dump returned an unexpected value")
    return graph


def pactl_json(pactl: str, *arguments: str) -> list[dict[str, Any]]:
    value = parse_json_output(
        run([pactl, "--format=json", *arguments]),
        "pactl",
    )
    if not isinstance(value, list):
        raise SessionError("pactl returned an unexpected value")
    return value


def properties(item: dict[str, Any]) -> dict[str, Any]:
    value = item.get("info", {}).get("props", {})
    return value if isinstance(value, dict) else {}


def target_node_id(graph: list[dict[str, Any]], target_name: str) -> int:
    for item in graph:
        if item.get("type") != "PipeWire:Interface:Node":
            continue
        if properties(item).get("node.name") == target_name:
            return int(item["id"])
    raise SessionError(f"PipeWire target not found: {target_name}")


def graph_links(graph: list[dict[str, Any]]) -> list[GraphLink]:
    links: list[GraphLink] = []
    for item in graph:
        if item.get("type") != "PipeWire:Interface:Link":
            continue
        props = properties(item)
        try:
            links.append(
                GraphLink(
                    link_id=int(item["id"]),
                    ports=LinkPorts(
                        output_port=int(props["link.output.port"]),
                        input_port=int(props["link.input.port"]),
                    ),
                    output_node=int(props["link.output.node"]),
                    input_node=int(props["link.input.node"]),
                )
            )
        except (KeyError, TypeError, ValueError) as error:
            raise SessionError(
                f"PipeWire link {item.get('id')} has no usable ports or nodes"
            ) from error
    return links


def target_links(graph: list[dict[str, Any]], target_id: int) -> list[GraphLink]:
    return [
        link
        for link in graph_links(graph)
        if link.output_node == target_id or link.input_node == target_id
    ]


def spotify_exclusive_node_ids(graph: list[dict[str, Any]]) -> set[int]:
    return {
        int(item["id"])
        for item in graph
        if item.get("type") == "PipeWire:Interface:Node"
        and properties(item).get("spotify.exclusive") == "enabled"
    }


def disconnect_target(
    pw_dump: str,
    pw_link: str,
    target_id: int,
    suspended: set[LinkPorts],
    protected_nodes: set[int] | None = None,
) -> int:
    protected = protected_nodes or set()
    before = len(suspended)
    for _attempt in range(20):
        links = [
            link
            for link in target_links(pipewire_dump(pw_dump), target_id)
            if link.output_node not in protected and link.input_node not in protected
        ]
        if not links:
            return len(suspended) - before
        for link in links:
            suspended.add(link.ports)
            run([pw_link, "-d", str(link.link_id)], check=False)
        time.sleep(0.05)

    graph = pipewire_dump(pw_dump)
    remaining = len(
        [
            link
            for link in target_links(graph, target_id)
            if link.output_node not in protected and link.input_node not in protected
        ]
    )
    raise SessionError(
        f"PipeWire target kept {remaining} non-exclusive link(s) after disconnecting them"
    )


def restore_links(pw_dump: str, pw_link: str, suspended: set[LinkPorts]) -> None:
    if not suspended:
        return

    deadline = time.monotonic() + 3
    graph: list[dict[str, Any]] = []
    while time.monotonic() < deadline:
        try:
            graph = pipewire_dump(pw_dump)
        except SessionError:
            time.sleep(0.1)
            continue
        if not spotify_exclusive_node_ids(graph):
            break
        time.sleep(0.05)

    try:
        graph = pipewire_dump(pw_dump)
    except SessionError as error:
        print(
            f"spotify-alsa: could not restore PipeWire links: {error}", file=sys.stderr
        )
        return

    port_ids = {
        int(item["id"])
        for item in graph
        if item.get("type") == "PipeWire:Interface:Port"
    }
    existing_links = {link.ports for link in graph_links(graph)}

    restored = 0
    for ports in sorted(suspended):
        if ports in existing_links:
            continue
        if ports.output_port not in port_ids or ports.input_port not in port_ids:
            continue
        result = run(
            [pw_link, "-w", str(ports.output_port), str(ports.input_port)],
            check=False,
        )
        if result.returncode == 0:
            restored += 1
        else:
            detail = result.stderr.strip() or result.stdout.strip() or "unknown error"
            print(
                f"spotify-alsa: could not restore link "
                f"{ports.output_port} -> {ports.input_port}: {detail}",
                file=sys.stderr,
            )
    if restored:
        print(f"spotify-alsa: restored {restored} PipeWire link(s)", file=sys.stderr)


def pulse_sinks(pactl: str) -> tuple[dict[str, int], dict[int, str]]:
    by_name: dict[str, int] = {}
    by_index: dict[int, str] = {}
    for item in pactl_json(pactl, "list", "sinks"):
        try:
            index = int(item["index"])
            name = str(item["name"])
        except (KeyError, TypeError, ValueError) as error:
            raise SessionError(
                "pactl returned a sink without a usable name or index"
            ) from error
        by_name[name] = index
        by_index[index] = name
    return by_name, by_index


def pulse_sink_inputs(pactl: str) -> dict[int, PulseSinkInput]:
    inputs: dict[int, PulseSinkInput] = {}
    for item in pactl_json(pactl, "list", "sink-inputs"):
        props = item.get("properties", {})
        if not isinstance(props, dict):
            props = {}
        try:
            sink_input = PulseSinkInput(
                index=int(item["index"]),
                sink=int(item["sink"]),
                properties=props,
            )
        except (KeyError, TypeError, ValueError) as error:
            raise SessionError(
                "pactl returned a sink input without usable indices"
            ) from error
        inputs[sink_input.index] = sink_input
    return inputs


def default_pulse_sink(pactl: str) -> str:
    name = run([pactl, "get-default-sink"]).stdout.strip()
    if not name:
        raise SessionError("PulseAudio compatibility server has no default sink")
    return name


def set_default_pulse_sink(pactl: str, sink_name: str) -> None:
    run([pactl, "set-default-sink", sink_name])


def move_pulse_sink_input(
    pactl: str,
    sink_input: int,
    destination: str,
) -> bool:
    result = run(
        [pactl, "move-sink-input", str(sink_input), destination],
        check=False,
    )
    return result.returncode == 0


def park_target_pulse_inputs(
    pactl: str,
    target_name: str,
    parking_name: str,
    moved_inputs: dict[int, str],
) -> int:
    sinks_by_name, sinks_by_index = pulse_sinks(pactl)
    try:
        target_index = sinks_by_name[target_name]
        sinks_by_name[parking_name]
    except KeyError as error:
        raise SessionError(f"PulseAudio sink not found: {error.args[0]}") from error

    parked = 0
    for sink_input in pulse_sink_inputs(pactl).values():
        if sink_input.sink != target_index or sink_input.is_spotify_exclusive:
            continue
        original_sink = sinks_by_index.get(sink_input.sink, target_name)
        if move_pulse_sink_input(
            pactl,
            sink_input.index,
            parking_name,
        ):
            moved_inputs.setdefault(sink_input.index, original_sink)
            parked += 1
            continue

        current = pulse_sink_inputs(pactl).get(sink_input.index)
        if current is not None and current.sink == target_index:
            raise SessionError(
                f"could not move PulseAudio sink input {sink_input.index} "
                f"to {parking_name}"
            )
    return parked


def restore_pulse_session(
    pactl: str,
    parking_name: str,
    original_default: str | None,
    initial_inputs: dict[int, PulseSinkInput],
    moved_inputs: dict[int, str],
) -> None:
    if original_default is None:
        return

    try:
        sinks_by_name, _sinks_by_index = pulse_sinks(pactl)
    except SessionError as error:
        print(
            f"spotify-alsa: could not restore PulseAudio routing: {error}",
            file=sys.stderr,
        )
        return

    if original_default in sinks_by_name:
        result = run(
            [pactl, "set-default-sink", original_default],
            check=False,
        )
        if result.returncode != 0:
            detail = result.stderr.strip() or result.stdout.strip() or "unknown error"
            print(
                f"spotify-alsa: could not restore default sink {original_default}: {detail}",
                file=sys.stderr,
            )
    else:
        print(
            f"spotify-alsa: original default sink disappeared: {original_default}",
            file=sys.stderr,
        )

    parking_index = sinks_by_name.get(parking_name)
    if parking_index is None:
        print(
            f"spotify-alsa: parking sink disappeared: {parking_name}",
            file=sys.stderr,
        )
        return

    try:
        current_inputs = pulse_sink_inputs(pactl)
    except SessionError as error:
        print(
            f"spotify-alsa: could not inspect parked streams: {error}", file=sys.stderr
        )
        return

    restored = 0
    for sink_input in current_inputs.values():
        if sink_input.sink != parking_index:
            continue

        destination = moved_inputs.get(sink_input.index)
        if destination is None and sink_input.index not in initial_inputs:
            destination = original_default
        if destination is None or destination == parking_name:
            continue
        if destination not in sinks_by_name:
            print(
                f"spotify-alsa: restore target disappeared for sink input "
                f"{sink_input.index}: {destination}",
                file=sys.stderr,
            )
            continue
        if move_pulse_sink_input(pactl, sink_input.index, destination):
            restored += 1

    if restored:
        print(
            f"spotify-alsa: restored {restored} PulseAudio stream(s)",
            file=sys.stderr,
        )


def spotify_is_running(pgrep: str) -> bool:
    result = run(
        [
            pgrep,
            "-u",
            str(os.getuid()),
            "-f",
            r"/share/spotify/\.spotify-wrapped",
        ],
        check=False,
    )
    if result.returncode not in (0, 1):
        detail = result.stderr.strip() or result.stdout.strip() or "unknown error"
        raise SessionError(f"Could not inspect Spotify processes: {detail}")
    return result.returncode == 0


def apply_profile(profile: str | None) -> None:
    if profile is None:
        return
    command = shutil.which("pipewire-profile")
    if command is None:
        raise SessionError(
            "pipewire-profile is required to activate the requested profile"
        )
    run([command, "set", profile], timeout=30)


def pulse_properties(target: str, rate: int) -> str:
    return " ".join(
        [
            "spotify.exclusive=enabled",
            "node.exclusive=true",
            "node.dont-fallback=true",
            "node.dont-move=true",
            f"node.force-rate={rate}",
            f"target.object={target}",
            "stream.dont-remix=true",
            "channelmix.disable=true",
            "resample.disable=true",
            "dither.method=none",
            "dither.noise=0",
        ]
    )


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Run Spotify on an exclusive PipeWire link"
    )
    parser.add_argument("--target", required=True)
    parser.add_argument("--parking-target", required=True)
    parser.add_argument("--rate", required=True, type=int)
    parser.add_argument("--spotify", required=True)
    parser.add_argument("--pactl", required=True)
    parser.add_argument("--pw-dump", required=True)
    parser.add_argument("--pw-link", required=True)
    parser.add_argument("--pgrep", required=True)
    parser.add_argument("--profile")
    parser.add_argument("--suspend-existing", action="store_true")
    parser.add_argument("spotify_args", nargs=argparse.REMAINDER)
    args = parser.parse_args()
    if args.spotify_args[:1] == ["--"]:
        args.spotify_args = args.spotify_args[1:]
    return args


def run_session(args: argparse.Namespace) -> int:
    runtime_dir = Path(os.environ.get("XDG_RUNTIME_DIR", f"/run/user/{os.getuid()}"))
    runtime_dir.mkdir(mode=0o700, parents=True, exist_ok=True)
    lock_path = runtime_dir / "spotify-alsa.lock"
    with lock_path.open("a+", encoding="utf-8") as lock:
        try:
            fcntl.flock(lock.fileno(), fcntl.LOCK_EX | fcntl.LOCK_NB)
        except BlockingIOError as error:
            raise SessionError(
                "another spotify-alsa session is already starting"
            ) from error

        if spotify_is_running(args.pgrep):
            raise SessionError(
                "another Spotify instance is already running; quit it before "
                "starting exclusive playback"
            )

        apply_profile(args.profile)
        graph = pipewire_dump(args.pw_dump)
        target_id = target_node_id(graph, args.target)
        initial_links = target_links(graph, target_id)

        initial_inputs: dict[int, PulseSinkInput] = {}
        moved_inputs: dict[int, str] = {}
        original_default: str | None = None
        suspended: set[LinkPorts] = set()
        child: subprocess.Popen[Any] | None = None

        if args.suspend_existing:
            if args.target == args.parking_target:
                raise SessionError("target and parking target must be different sinks")
            sinks_by_name, _sinks_by_index = pulse_sinks(args.pactl)
            for name in (args.target, args.parking_target):
                if name not in sinks_by_name:
                    raise SessionError(f"PulseAudio sink not found: {name}")
            initial_inputs = pulse_sink_inputs(args.pactl)
            original_default = default_pulse_sink(args.pactl)
        elif initial_links:
            raise SessionError(
                f"PipeWire target already has {len(initial_links)} link(s); "
                f"stop other clients using {args.target}"
            )

        try:
            if args.suspend_existing:
                set_default_pulse_sink(args.pactl, args.parking_target)
                parked = park_target_pulse_inputs(
                    args.pactl,
                    args.target,
                    args.parking_target,
                    moved_inputs,
                )
                disconnected = disconnect_target(
                    args.pw_dump,
                    args.pw_link,
                    target_id,
                    suspended,
                )
                if parked:
                    print(
                        f"spotify-alsa: parked {parked} PulseAudio stream(s)",
                        file=sys.stderr,
                    )
                if disconnected:
                    print(
                        f"spotify-alsa: suspended {disconnected} native PipeWire link(s)",
                        file=sys.stderr,
                    )

            environment = os.environ.copy()
            existing_properties = environment.get("PULSE_PROP", "").strip()
            requested_properties = pulse_properties(args.target, args.rate)
            environment["PULSE_PROP"] = " ".join(
                value for value in (existing_properties, requested_properties) if value
            )
            environment["PULSE_SINK"] = args.target

            try:
                child = subprocess.Popen(
                    [args.spotify, *args.spotify_args],
                    env=environment,
                )
            except OSError as error:
                raise SessionError(f"Could not start Spotify: {error}") from error

            def forward_signal(signum: int, _frame: Any) -> None:
                if child is not None and child.poll() is None:
                    child.send_signal(signum)

            for signum in (signal.SIGINT, signal.SIGTERM, signal.SIGHUP):
                signal.signal(signum, forward_signal)

            monitor_failures = 0
            while True:
                try:
                    return child.wait(timeout=0.2)
                except subprocess.TimeoutExpired:
                    if not args.suspend_existing:
                        continue
                    try:
                        park_target_pulse_inputs(
                            args.pactl,
                            args.target,
                            args.parking_target,
                            moved_inputs,
                        )
                        current_graph = pipewire_dump(args.pw_dump)
                        disconnect_target(
                            args.pw_dump,
                            args.pw_link,
                            target_id,
                            suspended,
                            spotify_exclusive_node_ids(current_graph),
                        )
                        monitor_failures = 0
                    except SessionError as error:
                        monitor_failures += 1
                        if monitor_failures >= 5:
                            raise SessionError(
                                f"could not maintain exclusive routing: {error}"
                            ) from error
        finally:
            if child is not None and child.poll() is None:
                child.terminate()
                try:
                    child.wait(timeout=5)
                except subprocess.TimeoutExpired:
                    child.kill()
                    child.wait()
            restore_pulse_session(
                args.pactl,
                args.parking_target,
                original_default,
                initial_inputs,
                moved_inputs,
            )
            restore_links(args.pw_dump, args.pw_link, suspended)


def main() -> int:
    args = parse_args()
    try:
        return run_session(args)
    except SessionError as error:
        print(f"spotify-alsa: {error}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
