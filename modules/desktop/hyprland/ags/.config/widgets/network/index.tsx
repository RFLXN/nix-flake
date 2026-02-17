import { LabeledWidgetButton } from "../../components/outer";
import { networkState } from "./state";
import { getNetworkIconLabel } from "./icons";
import NetworkPopover from "./popover";

export default function Network() {
  const icon = networkState.as(getNetworkIconLabel);
  const text = networkState.as((state) => {
    if (state.status === "wired") {
      return state.wired.info.interface ?? "";
    }
    if (state.status === "wifi") {
      return state.wifi.info.currentAp?.name ?? "";
    }
    return "";
  });

  return (
    <LabeledWidgetButton
      className="network"
      child={
        <box>
          <label label={icon} />
          <label label=" " />
          <label label={text} />
        </box>
      }
      menu={(menu) => <NetworkPopover state={networkState} open={menu.open} flip={menu.flip} />}
    />
  );
}
