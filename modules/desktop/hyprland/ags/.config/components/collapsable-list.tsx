import { Gtk } from "ags/gtk4";
import { For } from "gnim";
import type { Accessor } from "gnim";

type CollapsableListProps<Item> = {
  className: string;
  each: Accessor<Item[]>;
  spacing?: number;
  children: (item: Item) => JSX.Element;
};

export function CollapsableList<Item>({
  className,
  each,
  spacing = 2,
  children,
}: CollapsableListProps<Item>) {
  return (
    <box class={className} orientation={Gtk.Orientation.VERTICAL} spacing={spacing}>
      <For each={each}>{children}</For>
    </box>
  );
}

type CollapsableListItemProps = {
  className: string;
  header: JSX.Element;
  details?: JSX.Element | null;
  revealDetails?: boolean | Accessor<boolean>;
  spacing?: number;
  detailsClass?: string;
  transitionType?: Gtk.RevealerTransitionType;
  transitionDuration?: number;
};

export function CollapsableListItem({
  className,
  header,
  details = null,
  revealDetails = false,
  spacing = 4,
  detailsClass,
  transitionType = Gtk.RevealerTransitionType.SLIDE_DOWN,
  transitionDuration = 160,
}: CollapsableListItemProps) {
  if (!details) {
    return (
      <box class={className} orientation={Gtk.Orientation.VERTICAL} spacing={spacing}>
        {header}
      </box>
    );
  }

  return (
    <box class={className} orientation={Gtk.Orientation.VERTICAL} spacing={spacing}>
      {header}
      <revealer
        class={detailsClass}
        transitionType={transitionType}
        transitionDuration={transitionDuration}
        revealChild={revealDetails}
      >
        {details}
      </revealer>
    </box>
  );
}
