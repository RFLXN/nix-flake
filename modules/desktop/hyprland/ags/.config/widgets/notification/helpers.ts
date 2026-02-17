import AstalNotifd from "gi://AstalNotifd?version=0.1";
import Gio from "gi://Gio";
import GioUnix from "gi://GioUnix";

export const FALLBACK_ICON = "󰯪";

function isFilePath(value: string) {
  return value.startsWith("/") || value.startsWith("file://");
}

export function normalizeText(value: string) {
  return value.replace(/\s+/g, " ").trim();
}

export function getNotificationId(notification: AstalNotifd.Notification): number {
  return notification.id ?? notification.get_id?.() ?? 0;
}

export function normalizeTimestamp(value: number): number {
  if (!Number.isFinite(value) || value <= 0) return 0;
  return value < 1_000_000_000_000 ? value * 1000 : value;
}

export function getNotificationTimestampMs(notification: AstalNotifd.Notification): number {
  const timestamp = notification.time ?? notification.get_time?.() ?? 0;
  return normalizeTimestamp(timestamp);
}

export function getNotificationIcon(notification: AstalNotifd.Notification): Gio.Icon | null {
  const image = notification.image ?? "";
  if (image) {
    if (image.startsWith("file://")) {
      return Gio.FileIcon.new(Gio.File.new_for_uri(image));
    }
    if (isFilePath(image)) {
      return Gio.FileIcon.new(Gio.File.new_for_path(image));
    }
  }

  const appIcon = notification.app_icon ?? notification.appIcon ?? "";
  if (appIcon) {
    if (appIcon.startsWith("file://")) {
      return Gio.FileIcon.new(Gio.File.new_for_uri(appIcon));
    }
    if (isFilePath(appIcon)) {
      return Gio.FileIcon.new(Gio.File.new_for_path(appIcon));
    }
    return Gio.ThemedIcon.new(appIcon);
  }

  const desktopEntry = notification.desktop_entry ?? notification.desktopEntry ?? "";
  if (desktopEntry) {
    const appInfo = GioUnix.DesktopAppInfo.new(`${desktopEntry}.desktop`);
    const icon = appInfo?.get_icon?.();
    if (icon) return icon;
  }

  return null;
}

export function getNotificationContent(notification: AstalNotifd.Notification) {
  const appName = normalizeText(notification.app_name ?? notification.appName ?? "");
  const summary = normalizeText(notification.summary ?? "");
  const body = normalizeText(notification.body ?? "");
  const hasBody = body.length > 0;
  const titleText = hasBody ? summary : "";
  const bodyText = hasBody ? body : summary;
  const timestamp = getNotificationTimestampMs(notification);
  const actions = notification.actions ?? [];
  const hasActions = actions.length > 0;
  const useActionIcons = notification.action_icons ?? notification.actionIcons ?? false;

  return {
    appName,
    titleText,
    bodyText,
    timestamp,
    actions,
    hasActions,
    useActionIcons,
  };
}
