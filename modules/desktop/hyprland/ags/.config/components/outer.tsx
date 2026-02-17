import { Gtk } from "ags/gtk4";
import type { Accessor } from "gnim";
import { createMenuState } from "../utils/menu";

type MenuState = ReturnType<typeof createMenuState>;

type WidgetButtonProps = {
  className: string;
  child: JSX.Element;
  onClicked?: () => void;
  onSecondaryClick?: () => void;
  menu?: (state: MenuState) => JSX.Element;
};

type WidgetButtonBaseProps = WidgetButtonProps & {
  variant: "simple" | "labeled";
};

function attachSecondaryClick(self: Gtk.Widget, onSecondaryClick?: () => void) {
  if (!onSecondaryClick) return;

  const gesture = new Gtk.GestureClick();
  gesture.set_button(3);
  gesture.set_exclusive(false);
  gesture.connect("pressed", () => onSecondaryClick());
  self.add_controller(gesture);
}

function WidgetButtonBase({
  variant,
  className,
  child,
  onClicked,
  onSecondaryClick,
  menu,
}: WidgetButtonBaseProps) {
  const widgetClass = `widget ${className} widget-${variant}`;

  if (menu) {
    const menuState = createMenuState();
    return (
      <menubutton
        class={widgetClass}
        hasFrame={false}
        direction={Gtk.ArrowType.DOWN}
        child={child as unknown as Gtk.Widget}
        onNotifyActive={menuState.onNotifyActive}
        $={(self) => attachSecondaryClick(self, onSecondaryClick)}
      >
        {menu(menuState)}
      </menubutton>
    );
  }

  return (
    <button
      class={widgetClass}
      hasFrame={false}
      onClicked={onClicked}
      $={(self) => attachSecondaryClick(self, onSecondaryClick)}
    >
      {child}
    </button>
  );
}

export function SimpleWidgetButton(props: WidgetButtonProps) {
  return <WidgetButtonBase variant="simple" {...props} />;
}

export function LabeledWidgetButton(props: WidgetButtonProps) {
  return <WidgetButtonBase variant="labeled" {...props} />;
}

type CollapsibleWidgetProps = {
  className: string;
  collapsed: Accessor<boolean>;
  onToggle: () => void;
  children: JSX.Element | JSX.Element[];
  collapsedIcon?: string;
  expandedIcon?: string;
  spacing?: number;
  itemsClass?: string;
  toggleClass?: string;
  toggleWidthRequest?: number;
  toggleHeightRequest?: number;
};

export function CollapsibleWidget({
  className,
  collapsed,
  onToggle,
  children,
  collapsedIcon = "",
  expandedIcon = "",
  spacing = 2,
  itemsClass,
  toggleClass,
  toggleWidthRequest = 14,
  toggleHeightRequest = 14,
}: CollapsibleWidgetProps) {
  const showItems = collapsed.as((value) => !value);
  const toggleLabel = collapsed.as((value) => (value ? collapsedIcon : expandedIcon));
  const itemClassName = itemsClass ?? `${className}-items`;
  const toggleClassName = toggleClass ?? `tray-item ${className}-toggle`;

  return (
    <box class={`widget ${className}`} spacing={spacing}>
      <revealer
        revealChild={showItems}
        transitionType={Gtk.RevealerTransitionType.SLIDE_LEFT}
        transitionDuration={140}
      >
        <box class={itemClassName} spacing={spacing}>
          {children}
        </box>
      </revealer>
      <button
        class={toggleClassName}
        hasFrame={false}
        canShrink
        widthRequest={toggleWidthRequest}
        heightRequest={toggleHeightRequest}
        onClicked={onToggle}
      >
        <label label={toggleLabel} />
      </button>
    </box>
  );
}
