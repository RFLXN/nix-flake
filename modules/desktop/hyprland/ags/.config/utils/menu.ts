import { createComputed, createState } from "gnim";
import type { Accessor } from "gnim";

type MenuToggleTarget = {
  active: boolean;
};

export function createMenuState(initialOpen = false) {
  const [open, setOpen] = createState(initialOpen);
  const [flip, setFlip] = createState(false);

  const onNotifyActive = (self: MenuToggleTarget) => {
    if (self.active) {
      setOpen(true);
      setFlip((value) => !value);
      return;
    }
    setOpen(false);
  };

  return {
    open,
    flip,
    onNotifyActive,
  };
}

export function createMenuClass(
  baseClass: string,
  open: Accessor<boolean>,
  flip: Accessor<boolean>,
) {
  return createComputed(() => `${baseClass}${open() ? " open" : ""} ${flip() ? "anim-a" : "anim-b"}`);
}
