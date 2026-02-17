import AstalTray from "gi://AstalTray?version=0.1";
import { Gtk } from "ags/gtk4";
import { Accessor, For, createConnection, createState } from "gnim";
import { CollapsibleWidget } from "../../components/outer";

const tray = AstalTray.get_default();
const ICON_SIZE = 14;
const BUTTON_SIZE = 14;

function listItems() {
  if (!tray) return [];
  return tray.items ?? [];
}

const emptyItems = new Accessor<AstalTray.TrayItem[]>(() => [], () => () => {});

const trayItems = tray
  ? createConnection(
      listItems(),
      [tray, "notify::items", () => listItems()],
      [tray, "item-added", () => listItems()],
      [tray, "item-removed", () => listItems()],
    )
  : emptyItems;

function TrayButton({ item }: { item: AstalTray.TrayItem }) {
  const gicon = createConnection(
    item.gicon,
    [item, "notify::gicon", () => item.gicon],
    [item, "changed", () => item.gicon],
  );
  const menuModel = createConnection(
    item.menuModel,
    [item, "notify::menu-model", () => item.menuModel],
    [item, "changed", () => item.menuModel],
  );
  const actionGroup = createConnection(
    item.actionGroup,
    [item, "notify::action-group", () => item.actionGroup],
    [item, "changed", () => item.actionGroup],
  );
  const icon = <image gicon={gicon} pixelSize={ICON_SIZE} />;

  if (item.menuModel) {
    return (
      <menubutton
        class="tray-item"
        hasFrame={false}
        canShrink
        widthRequest={BUTTON_SIZE}
        heightRequest={BUTTON_SIZE}
        alwaysShowArrow={false}
        menuModel={menuModel}
        child={icon as unknown as Gtk.Widget}
        onNotifyActive={(self) => {
          if (self.active) {
            item.about_to_show();
            const group = actionGroup();
            if (group) {
              self.insert_action_group("dbusmenu", group);
            } else {
              self.insert_action_group("dbusmenu", null);
            }
          }
        }}
      />
    );
  }

  return (
    <button
      class="tray-item"
      hasFrame={false}
      canShrink
      widthRequest={BUTTON_SIZE}
      heightRequest={BUTTON_SIZE}
      onClicked={() => item.activate(0, 0)}
    >
      {icon}
    </button>
  );
}

export default function Tray() {
  const [collapsed, setCollapsed] = createState(true);

  return (
    <CollapsibleWidget
      className="tray"
      collapsed={collapsed}
      onToggle={() => setCollapsed((value) => !value)}
      toggleWidthRequest={BUTTON_SIZE}
      toggleHeightRequest={BUTTON_SIZE}
    >
      <For each={trayItems}>{(item) => <TrayButton item={item} />}</For>
    </CollapsibleWidget>
  );
}
