import AstalNotifd from "gi://AstalNotifd?version=0.1";
import { Accessor, createConnection } from "gnim";

export const notifd = AstalNotifd.get_default();

const emptyList = new Accessor<AstalNotifd.Notification[]>(() => [], () => () => {});

export const notifications = notifd
  ? createConnection(
      notifd.notifications ?? [],
      [notifd, "notify::notifications", () => notifd.notifications ?? []],
      [notifd, "notified", () => notifd.notifications ?? []],
      [notifd, "resolved", () => notifd.notifications ?? []],
    )
  : emptyList;
