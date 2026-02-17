import GLib from "gi://GLib";
import { Gtk } from "ags/gtk4";
import { createState } from "gnim";
import type { Accessor } from "gnim";
import { WidgetPopover } from "../../components/popover";

type ClockPopoverProps = {
  open: Accessor<boolean>;
  flip: Accessor<boolean>;
};

type VisibleDate = {
  year: number;
  month: number;
};

const MONTH_SHORT_NAMES = [
  "Jan",
  "Feb",
  "Mar",
  "Apr",
  "May",
  "Jun",
  "Jul",
  "Aug",
  "Sep",
  "Oct",
  "Nov",
  "Dec",
] as const;

function getToday() {
  const now = new Date();
  return {
    year: now.getFullYear(),
    month: now.getMonth(),
    day: now.getDate(),
  };
}

function daysInMonth(year: number, month: number): number {
  return new Date(year, month + 1, 0).getDate();
}

function moveMonth({ year, month }: VisibleDate, delta: -1 | 1): VisibleDate {
  let nextYear = year;
  let nextMonth = month + delta;

  if (nextMonth > 11) {
    nextMonth = 0;
    nextYear += 1;
  } else if (nextMonth < 0) {
    nextMonth = 11;
    nextYear -= 1;
  }

  return { year: nextYear, month: nextMonth };
}

export default function ClockPopover({ open, flip }: ClockPopoverProps) {
  const today = getToday();
  const [visibleDate, setVisibleDate] = createState<VisibleDate>({
    year: today.year,
    month: today.month,
  });
  let selectedDay = today.day;
  let calendar: Gtk.Calendar | null = null;

  const syncFromCalendar = () => {
    if (!calendar) return;
    selectedDay = calendar.day;
    setVisibleDate({ year: calendar.year, month: calendar.month });
  };

  const applyDateToCalendar = (year: number, month: number, day: number) => {
    if (!calendar) return;
    const date = GLib.DateTime.new_local(year, month + 1, day, 12, 0, 0);
    if (!date) return;
    calendar.set_date(date);
  };

  const selectDate = (year: number, month: number, day: number) => {
    const clampedDay = Math.max(1, Math.min(day, daysInMonth(year, month)));
    selectedDay = clampedDay;
    applyDateToCalendar(year, month, clampedDay);
  };

  const resetToTodayState = () => {
    const current = getToday();
    selectedDay = current.day;
    setVisibleDate({ year: current.year, month: current.month });
    return current;
  };

  const jumpToToday = () => {
    const current = resetToTodayState();
    selectDate(current.year, current.month, current.day);
  };

  const shiftMonth = (delta: -1 | 1) => {
    const next = moveMonth(visibleDate(), delta);
    setVisibleDate(next);
    selectDate(next.year, next.month, selectedDay);
  };

  const resetCalendarToToday = () => {
    const current = resetToTodayState();
    applyDateToCalendar(current.year, current.month, current.day);
  };

  const syncByPopoverVisibility = (visible: boolean) => {
    if (visible) {
      jumpToToday();
      return;
    }
    resetCalendarToToday();
  };

  const yearLabel = visibleDate.as((date) => String(date.year));
  const monthLabel = visibleDate.as((date) => {
    const number = String(date.month + 1).padStart(2, "0");
    const short = MONTH_SHORT_NAMES[date.month] ?? "";
    return `${number} (${short})`;
  });

  return (
    <WidgetPopover
      popoverClass="clock-popover"
      menuClassName="clock-menu"
      open={open}
      flip={flip}
      setup={(self) => {
        const sync = () => syncByPopoverVisibility(self.visible);
        self.connect("notify::visible", () => sync());
        self.connect("closed", () => resetCalendarToToday());
        sync();
      }}
    >
      <box class="clock-calendar-header-row" spacing={8}>
        <button class="clock-calendar-nav" onClicked={() => shiftMonth(-1)}>
          <label label="<" />
        </button>
        <box class="clock-calendar-title" orientation={Gtk.Orientation.VERTICAL} spacing={0} hexpand>
          <label class="clock-calendar-year" label={yearLabel} xalign={0.5} />
          <label class="clock-calendar-month" label={monthLabel} xalign={0.5} />
        </box>
        <button class="clock-calendar-nav" onClicked={() => shiftMonth(1)}>
          <label label=">" />
        </button>
      </box>
      <Gtk.Separator class="clock-calendar-separator" orientation={Gtk.Orientation.HORIZONTAL} />
      <Gtk.Calendar
        class="clock-calendar"
        showHeading={false}
        showDayNames={true}
        showWeekNumbers={false}
        $={(self) => {
          calendar = self;
          selectDate(visibleDate().year, visibleDate().month, selectedDay);
          self.connect("notify::month", () => syncFromCalendar());
          self.connect("notify::year", () => syncFromCalendar());
          self.connect("day-selected", () => syncFromCalendar());
          syncFromCalendar();
        }}
      />
    </WidgetPopover>
  );
}
