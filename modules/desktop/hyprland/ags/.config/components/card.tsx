import { Gtk } from "ags/gtk4";
import type { Accessor } from "gnim";

type CardProps = {
  header: JSX.Element | null;
  main: JSX.Element;
  footer: JSX.Element | null;
  className?: string | Accessor<string>;
  spacing?: number;
  orientation?: Gtk.Orientation;
};

export function Card({
  header,
  main,
  footer,
  className,
  spacing = 0,
  orientation = Gtk.Orientation.VERTICAL,
}: CardProps) {
  return (
    <box class={className} orientation={orientation} spacing={spacing}>
      {header ? header : null}
      {main}
      {footer ? footer : null}
    </box>
  );
}
