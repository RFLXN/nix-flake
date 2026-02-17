import GLib from "gi://GLib";
import { Accessor } from "gnim";
import { LabeledWidgetButton } from "../../components/outer";
import ClockPopover from "./popover";

type ClockProps = {
  format?: string;
};

function formatNow(format: string): string {
  try {
    const now = GLib.DateTime.new_now_local();
    return now ? now.format(format) ?? "" : "";
  } catch {
    return "";
  }
}

export default function Clock({ format = "%Y-%m-%d %I:%M:%S %p" }: ClockProps) {
  const time = new Accessor<string>(
    () => formatNow(format),
    (notify) => {
      const id = GLib.timeout_add(GLib.PRIORITY_DEFAULT, 1000, () => {
        notify();
        return GLib.SOURCE_CONTINUE;
      });

      return () => {
        GLib.Source.remove(id);
      };
    },
  );

  return (
    <LabeledWidgetButton
      className="clock"
      child={
        <box>
          <label label=" " />
          <label label={time} />
        </box>
      }
      menu={(menu) => <ClockPopover open={menu.open} flip={menu.flip} />}
    />
  );
}
