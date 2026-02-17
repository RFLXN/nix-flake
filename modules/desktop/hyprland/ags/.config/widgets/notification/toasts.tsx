import AstalNotifd from "gi://AstalNotifd?version=0.1";
import GLib from "gi://GLib";
import Pango from "gi://Pango";
import { Astal, Gtk } from "ags/gtk4";
import { Accessor, For, createComputed } from "gnim";
import { notifd, notifications } from "./store";
import { formatNotificationTime, now } from "./time";
import { isFocusedFullscreen, isFocusedMaximized } from "../../utils/fullscreen";
import {
  FALLBACK_ICON,
  getNotificationId,
  getNotificationContent,
  getNotificationIcon,
} from "./helpers";
const TOAST_DURATION_MS = 5000;

const emptyIds = new Accessor<number[]>(() => [], () => () => {});

const toastIds = notifd
  ? (() => {
      let orderedIds: number[] = [];
      const timeoutById = new Map<number, number>();

      const clearExpiry = (id: number) => {
        const sourceId = timeoutById.get(id);
        if (sourceId !== undefined) {
          GLib.Source.remove(sourceId);
          timeoutById.delete(id);
        }
      };

      const scheduleExpiry = (id: number, notify: () => void) => {
        clearExpiry(id);
        const sourceId = GLib.timeout_add(GLib.PRIORITY_DEFAULT, TOAST_DURATION_MS, () => {
          timeoutById.delete(id);
          const next = orderedIds.filter((value) => value !== id);
          if (next.length !== orderedIds.length) {
            orderedIds = next;
            notify();
          }
          return GLib.SOURCE_REMOVE;
        });
        timeoutById.set(id, sourceId);
      };

      const removeToast = (id: number, notify: () => void) => {
        if (!id) return;
        clearExpiry(id);
        const next = orderedIds.filter((value) => value !== id);
        if (next.length !== orderedIds.length) {
          orderedIds = next;
          notify();
        }
      };

      return new Accessor<number[]>(
        () => orderedIds,
        (notify) => {
          const addToastById = (id: number) => {
            if (!id) return;
            const notification = notifd.get_notification(id);
            if (notification?.urgency === AstalNotifd.Urgency.LOW) return;
            orderedIds = [id, ...orderedIds.filter((value) => value !== id)];
            notify();
            scheduleExpiry(id, notify);
          };
          const notifiedId = notifd.connect("notified", (_d, id: number) => addToastById(id));
          const resolvedId = notifd.connect("resolved", (_d, id: number) => removeToast(id, notify));
          return () => {
            notifd.disconnect(notifiedId);
            notifd.disconnect(resolvedId);
            timeoutById.forEach((sourceId) => GLib.Source.remove(sourceId));
            timeoutById.clear();
            orderedIds = [];
          };
        },
      );
    })()
  : emptyIds;

export default function NotificationToasts() {
  const { BOTTOM, LEFT } = Astal.WindowAnchor;
  const toastList = createComputed(() => {
    const ids = toastIds();
    const list = notifications();
    const map = new Map(list.map((item) => [getNotificationId(item), item]));
    return ids
      .map((id) => map.get(id))
      .filter((item): item is AstalNotifd.Notification => Boolean(item));
  });
  const visible = createComputed(
    () => toastList().length > 0 && !isFocusedMaximized() && !isFocusedFullscreen(),
  );

  return (
    <window
      class="notification-toast-window"
      visible={visible}
      anchor={BOTTOM | LEFT}
      layer={Astal.Layer.TOP}
      exclusivity={Astal.Exclusivity.IGNORE}
    >
      <box class="notification-toast-container" orientation={Gtk.Orientation.VERTICAL} spacing={8}>
        <For each={toastList}>
          {(notification) => {
            const icon = getNotificationIcon(notification);
            const {
              appName,
              titleText,
              bodyText,
              timestamp,
              actions,
              hasActions,
              useActionIcons,
            } = getNotificationContent(notification);
            const timeLabel = now.as((current) => formatNotificationTime(timestamp, current));
            const itemClass = `notification-item toast-item${hasActions ? " has-actions" : ""}`;
            return (
              <box class={itemClass} orientation={Gtk.Orientation.VERTICAL} spacing={4}>
                <box class="notification-item-header" spacing={6}>
                  {icon ? (
                    <image class="notification-item-icon" gicon={icon} pixelSize={20} />
                  ) : (
                    <label class="notification-item-icon" label={FALLBACK_ICON} />
                  )}
                  <label
                    class="notification-item-app"
                    label={appName || "Notification"}
                    hexpand
                    xalign={0}
                    ellipsize={Pango.EllipsizeMode.END}
                    maxWidthChars={30}
                    lines={1}
                  />
                  <label class="notification-item-time" label={timeLabel} />
                  <button class="notification-item-close" onClicked={() => notification.dismiss()}>
                    <label label="󰅖" />
                  </button>
                </box>
                <Gtk.Separator class="notification-item-sep" orientation={Gtk.Orientation.HORIZONTAL} />
                <label
                  class="notification-item-title"
                  label={titleText}
                  visible={titleText.length > 0}
                  hexpand
                  xalign={0}
                  ellipsize={Pango.EllipsizeMode.END}
                  maxWidthChars={34}
                  lines={1}
                />
                <label
                  class="notification-item-body"
                  label={bodyText}
                  hexpand
                  vexpand
                  xalign={0}
                  yalign={0}
                  wrap
                  wrapMode={Pango.WrapMode.WORD_CHAR}
                  ellipsize={Pango.EllipsizeMode.END}
                  maxWidthChars={36}
                  lines={3}
                />
                <box class="notification-item-actions" spacing={6} visible={hasActions}>
                  {actions.map((action) => (
                    <button
                      class="notification-item-action"
                      onClicked={() => notification.invoke(action.id)}
                    >
                      {useActionIcons ? (
                        <image iconName={action.id} pixelSize={16} />
                      ) : (
                        <label
                          label={action.label}
                          ellipsize={Pango.EllipsizeMode.END}
                          maxWidthChars={12}
                          lines={1}
                        />
                      )}
                    </button>
                  ))}
                </box>
              </box>
            );
          }}
        </For>
      </box>
    </window>
  );
}
