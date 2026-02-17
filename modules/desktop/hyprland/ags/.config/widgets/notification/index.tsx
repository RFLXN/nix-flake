import { SimpleWidgetButton } from "../../components/outer";
import NotificationPopover from "./popover";
import { notifications } from "./store";

const ICON_EMPTY = "󰯪";
const ICON_UNREAD = "󰞏";

export default function Notification() {
  const label = notifications.as((list) => {
    return list.length > 0 ? ICON_UNREAD : ICON_EMPTY;
  });

  return (
    <SimpleWidgetButton
      className="notification"
      child={<label label={label} />}
      menu={(menu) => (
        <NotificationPopover notifications={notifications} open={menu.open} flip={menu.flip} />
      )}
    />
  );
}
