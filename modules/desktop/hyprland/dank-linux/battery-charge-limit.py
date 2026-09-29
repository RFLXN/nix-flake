"""Apply DMS charge limits through sysfs and verify the hardware readback."""

import argparse
import json
from pathlib import Path
import sys


POWER_SUPPLY = Path("/sys/class/power_supply")


def batteries():
    result = []
    for device in sorted(POWER_SUPPLY.iterdir()):
        if (device / "type").read_text().strip() != "Battery":
            continue
        # Only percentage thresholds; charge_control_limit_max is a current limit.
        for name in ("charge_control_end_threshold", "charge_stop_threshold"):
            threshold = device / name
            if threshold.exists():
                result.append((device.name, threshold))
                break
    if not result:
        raise RuntimeError("No battery with a supported charge threshold was found.")
    return result


def read_limits(devices):
    return {name: int(path.read_text().strip()) for name, path in devices}


def apply_limit(devices, requested):
    previous = read_limits(devices)
    changed = []
    try:
        for name, path in devices:
            changed.append((name, path))
            path.write_text(f"{requested}\n")
        actual = read_limits(devices)
        if any(value != requested for value in actual.values()):
            values = ", ".join(f"{name}: {value}%" for name, value in actual.items())
            raise RuntimeError(f"Requested {requested}%, but hardware reported {values}.")
        return actual
    except (OSError, ValueError, RuntimeError) as error:
        restore_errors = []
        for name, path in reversed(changed):
            try:
                path.write_text(f"{previous[name]}\n")
                if int(path.read_text().strip()) != previous[name]:
                    raise RuntimeError("readback differs from the previous limit")
            except (OSError, ValueError, RuntimeError) as restore_error:
                restore_errors.append(f"{name}: {restore_error}")
        detail = (
            " Restore failed: " + "; ".join(restore_errors)
            if restore_errors else " Previous limits restored."
        )
        raise RuntimeError(str(error) + detail) from error


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--limit", type=int)
    args = parser.parse_args()
    try:
        if args.limit is not None and not 50 <= args.limit <= 100:
            raise RuntimeError("Charge limit must be between 50 and 100 percent.")
        devices = batteries()
        actual = read_limits(devices) if args.limit is None else apply_limit(devices, args.limit)
        values = ", ".join(f"{name}: {value}%" for name, value in actual.items())
        print(json.dumps({"ok": True, "actual": actual, "message": values}))
        return 0
    except (OSError, ValueError, RuntimeError) as error:
        print(json.dumps({"ok": False, "message": str(error)}))
        return 1


if __name__ == "__main__":
    sys.exit(main())
