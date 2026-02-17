import GLib from "gi://GLib";
import { Accessor } from "gnim";
import { normalizeTimestamp } from "./helpers";

const UPDATE_INTERVAL_MS = 1000;

export const now = new Accessor<number>(
  () => Date.now(),
  (notify) => {
    const id = GLib.timeout_add(GLib.PRIORITY_DEFAULT, UPDATE_INTERVAL_MS, () => {
      notify();
      return GLib.SOURCE_CONTINUE;
    });
    return () => {
      GLib.Source.remove(id);
    };
  },
);

function formatAbsolute(timeMs: number): string {
  const date = new Date(timeMs);
  const month = `${date.getMonth() + 1}`.padStart(2, "0");
  const day = `${date.getDate()}`.padStart(2, "0");
  let hours = date.getHours();
  const ampm = hours >= 12 ? "PM" : "AM";
  hours = hours % 12;
  if (hours === 0) hours = 12;
  const hourText = `${hours}`.padStart(2, "0");
  const minuteText = `${date.getMinutes()}`.padStart(2, "0");
  return `${month}-${day} ${hourText}:${minuteText} ${ampm}`;
}

export function formatNotificationTime(time: number, nowMs: number): string {
  const timeMs = normalizeTimestamp(time);
  if (!timeMs) return "";
  const diffSec = Math.max(0, Math.floor((nowMs - timeMs) / 1000));
  if (diffSec < 60) return `${diffSec}s ago`;
  const diffMin = Math.floor(diffSec / 60);
  if (diffMin < 60) return `${diffMin}m ago`;
  const diffHour = Math.floor(diffMin / 60);
  if (diffHour <= 6) return `${diffHour}h ago`;
  return formatAbsolute(timeMs);
}
