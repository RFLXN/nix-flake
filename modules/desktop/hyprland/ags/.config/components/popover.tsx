import { Gtk } from "ags/gtk4";
import type { Accessor } from "gnim";
import { createMenuClass } from "../utils/menu";

type PopoverChildren = JSX.Element | JSX.Element[];

type WidgetPopoverProps = {
  popoverClass: string;
  menuClassName: string;
  open: Accessor<boolean>;
  flip: Accessor<boolean>;
  children: PopoverChildren;
  setup?: (self: Gtk.Popover) => void;
};

export function WidgetPopover({
  popoverClass,
  menuClassName,
  open,
  flip,
  children,
  setup,
}: WidgetPopoverProps) {
  const menuClass = createMenuClass(menuClassName, open, flip);

  return (
    <popover
      class={popoverClass}
      hasArrow={true}
      position={Gtk.PositionType.BOTTOM}
      $={(self) => setup?.(self)}
    >
      <box class={menuClass} orientation={Gtk.Orientation.VERTICAL} spacing={0}>
        {children}
      </box>
    </popover>
  );
}

type PopoverTitleBlockProps = {
  containerClass: string;
  titleClass: string;
  title: string | Accessor<string>;
  spacing?: number;
  xalign?: number;
};

export function PopoverTitleBlock({
  containerClass,
  titleClass,
  title,
  spacing = 6,
  xalign = 0.5,
}: PopoverTitleBlockProps) {
  return (
    <box class={containerClass} orientation={Gtk.Orientation.VERTICAL} spacing={spacing}>
      <label class={titleClass} label={title} xalign={xalign} />
      <Gtk.Separator orientation={Gtk.Orientation.HORIZONTAL} />
    </box>
  );
}

type PopoverEmptyStateProps = {
  className: string;
  visible: boolean | Accessor<boolean>;
  label: string;
};

export function PopoverEmptyState({ className, visible, label }: PopoverEmptyStateProps) {
  return (
    <box class={className} visible={visible}>
      <label label={label} />
    </box>
  );
}

type PopoverScrollAreaProps = {
  className: string;
  children: PopoverChildren;
  visible?: boolean | Accessor<boolean>;
  maxContentHeight?: number;
};

export function PopoverScrollArea({
  className,
  children,
  visible,
  maxContentHeight = 240,
}: PopoverScrollAreaProps) {
  return (
    <scrolledwindow
      class={className}
      visible={visible}
      vscrollbarPolicy={Gtk.PolicyType.AUTOMATIC}
      hscrollbarPolicy={Gtk.PolicyType.NEVER}
      propagateNaturalHeight={true}
      minContentHeight={0}
      maxContentHeight={maxContentHeight}
    >
      {children}
    </scrolledwindow>
  );
}
