import AstalNotifd from "gi://AstalNotifd?version=0.1";
import GLib from "gi://GLib";
import Pango from "gi://Pango";
import { Gtk } from "ags/gtk4";
import { Accessor, For, createComputed, createState } from "gnim";
import { Card } from "../../components/card";
import { formatNotificationTime, now } from "./time";
import {
  PopoverEmptyState,
  PopoverScrollArea,
  WidgetPopover,
} from "../../components/popover";
import {
  FALLBACK_ICON,
  getNotificationId,
  getNotificationContent,
  getNotificationIcon,
  getNotificationTimestampMs,
} from "./helpers";

type NotificationPopoverProps = {
  notifications: Accessor<AstalNotifd.Notification[]>;
  open: Accessor<boolean>;
  flip: Accessor<boolean>;
};

export default function NotificationPopover({ notifications, open, flip }: NotificationPopoverProps) {
  const [dismissing, setDismissing] = createState<Set<number>>(new Set());
  const list = notifications.as((items) =>
    [...items].sort((a, b) => getNotificationTimestampMs(b) - getNotificationTimestampMs(a)),
  );
  const showEmpty = notifications.as((items) => items.length === 0);
  const showList = showEmpty.as((value) => !value);
  const scheduleDismiss = (notification: AstalNotifd.Notification) => {
    const id = getNotificationId(notification);
    if (!id) {
      notification.dismiss();
      return;
    }
    setDismissing((prev) => {
      const next = new Set(prev);
      next.add(id);
      return next;
    });
    GLib.timeout_add(GLib.PRIORITY_DEFAULT, 160, () => {
      notification.dismiss();
      setDismissing((prev) => {
        const next = new Set(prev);
        next.delete(id);
        return next;
      });
      return GLib.SOURCE_REMOVE;
    });
  };
  const clearAll = () => {
    const items = notifications();
    if (!items.length) return;
    items.forEach((notification) => scheduleDismiss(notification));
  };

  return (
    <WidgetPopover
      popoverClass="notification-popover"
      menuClassName="notification-menu"
      open={open}
      flip={flip}
    >
      <box class="notification-header" orientation={Gtk.Orientation.VERTICAL} spacing={0}>
        <box class="notification-header-row" spacing={6}>
          <box class="notification-header-spacer" visible={showList} />
          <label class="notification-header-title" label="Notifications" hexpand xalign={0.5} />
          <button
            class="notification-header-action"
            visible={showList}
            onClicked={clearAll}
          >
            <label label="Clear" />
          </button>
        </box>
      </box>
      <PopoverEmptyState className="notification-empty" visible={showEmpty} label="No notifications" />
      <PopoverScrollArea className="notification-scroll" visible={showList} maxContentHeight={600}>
        <box class="notification-list" orientation={Gtk.Orientation.VERTICAL} spacing={0}>
          <For each={list}>
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
              const itemClass = createComputed(() => {
                const id = getNotificationId(notification);
                const dismissClass = dismissing().has(id) ? " dismissing" : "";
                const actionClass = hasActions ? " has-actions" : "";
                return `notification-item${actionClass}${dismissClass}`;
              });
              const header = (
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
                  <button class="notification-item-close" onClicked={() => scheduleDismiss(notification)}>
                    <label label="󰅖" />
                  </button>
                </box>
              );
              const main = (
                <box orientation={Gtk.Orientation.VERTICAL} spacing={4}>
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
                </box>
              );
              const footer = hasActions ? (
                <box class="notification-item-actions" spacing={6}>
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
              ) : null;
              return (
                <Card className={itemClass} header={header} main={main} footer={footer} spacing={4} />
              );
            }}
          </For>
        </box>
      </PopoverScrollArea>
    </WidgetPopover>
  );
}
