import AstalWp from "gi://AstalWp?version=0.1";
import { Gtk } from "ags/gtk4";
import { Accessor, For, createConnection } from "gnim";
import {
  PopoverEmptyState,
  PopoverTitleBlock,
  WidgetPopover,
} from "../../components/popover";

const wp = AstalWp.Wp.get_default();
const audio = wp?.audio ?? null;

const emptySpeakers = new Accessor<AstalWp.Endpoint[]>(() => [], () => () => {});
const emptyMicrophones = new Accessor<AstalWp.Endpoint[]>(() => [], () => () => {});

function listSpeakers() {
  if (!audio) return [];
  return audio.speakers ?? [];
}

function listMicrophones() {
  if (!audio) return [];
  return audio.microphones ?? [];
}

const speakers = audio
  ? createConnection(
      listSpeakers(),
      [audio, "notify::speakers", () => listSpeakers()],
      [audio, "speaker-added", () => listSpeakers()],
      [audio, "speaker-removed", () => listSpeakers()],
      [wp, "notify::default-speaker", () => listSpeakers()],
    )
  : emptySpeakers;

const microphones = audio
  ? createConnection(
      listMicrophones(),
      [audio, "notify::microphones", () => listMicrophones()],
      [audio, "microphone-added", () => listMicrophones()],
      [audio, "microphone-removed", () => listMicrophones()],
      [wp, "notify::default-microphone", () => listMicrophones()],
    )
  : emptyMicrophones;

function getEndpointName(endpoint: AstalWp.Endpoint): string {
  return (
    endpoint.description ??
    endpoint.get_description?.() ??
    endpoint.name ??
    endpoint.get_name?.() ??
    "Output"
  );
}

function getEndpointMuted(endpoint: AstalWp.Endpoint): boolean {
  if (typeof endpoint.mute === "boolean") return endpoint.mute;
  if (typeof endpoint.get_mute === "function") return endpoint.get_mute();
  return false;
}

function getEndpointVolume(endpoint: AstalWp.Endpoint): number {
  if (typeof endpoint.volume === "number") return endpoint.volume;
  if (typeof endpoint.get_volume === "function") return endpoint.get_volume();
  return 0;
}

function getEndpointDefault(endpoint: AstalWp.Endpoint): boolean {
  if (typeof endpoint.isDefault === "boolean") return endpoint.isDefault;
  if (typeof endpoint.is_default === "boolean") return endpoint.is_default;
  if (typeof endpoint.get_is_default === "function") return endpoint.get_is_default();
  return false;
}

function setEndpointDefault(endpoint: AstalWp.Endpoint): void {
  if (typeof endpoint.set_is_default === "function") {
    endpoint.set_is_default(true);
  } else if (typeof endpoint.isDefault === "boolean") {
    endpoint.isDefault = true;
  } else {
    endpoint.is_default = true;
  }
}

function toggleEndpointMute(endpoint: AstalWp.Endpoint): void {
  const muted = getEndpointMuted(endpoint);
  if (typeof endpoint.set_mute === "function") {
    endpoint.set_mute(!muted);
  } else {
    endpoint.mute = !muted;
  }
}

function setEndpointVolume(endpoint: AstalWp.Endpoint, volume: number): void {
  const value = Math.max(0, Math.min(1, volume));
  if (typeof endpoint.set_volume === "function") {
    endpoint.set_volume(value);
  } else {
    endpoint.volume = value;
  }
}

const ICONS = {
  muted: "󰖁",
  unmuted: "󰕾",
} as const;

type VolumePopoverProps = {
  open: Accessor<boolean>;
  flip: Accessor<boolean>;
};

type EndpointListProps = {
  endpoints: Accessor<AstalWp.Endpoint[]>;
};

function EndpointList({ endpoints }: EndpointListProps) {
  return (
    <For each={endpoints}>
      {(endpoint) => {
        const muted = createConnection(
          getEndpointMuted(endpoint),
          [endpoint, "notify::mute", () => getEndpointMuted(endpoint)],
        );
        const volume = createConnection(
          getEndpointVolume(endpoint),
          [endpoint, "notify::volume", () => getEndpointVolume(endpoint)],
        );
        const isDefault = createConnection(
          getEndpointDefault(endpoint),
          [endpoint, "notify::is-default", () => getEndpointDefault(endpoint)],
        );
        return (
          <box class="volume-device" orientation={Gtk.Orientation.VERTICAL} spacing={0}>
            <box class="volume-device-row" spacing={2}>
              <Gtk.CheckButton
                class="volume-device-default-toggle"
                active={isDefault}
                onToggled={(self) => {
                  if (self.active) {
                    setEndpointDefault(endpoint);
                    return;
                  }
                  if (isDefault()) {
                    self.active = true;
                  }
                }}
              />
              <label class="volume-device-name" label={getEndpointName(endpoint)} hexpand xalign={0} />
            </box>
            <box class="volume-slider-row" spacing={6}>
              <button class="volume-device-mute" onClicked={() => toggleEndpointMute(endpoint)}>
                <label label={muted.as((value) => (value ? ICONS.muted : ICONS.unmuted))} />
              </button>
              <slider
                class="volume-slider"
                hexpand
                value={volume}
                min={0}
                max={1}
                step={0.01}
                page={0.05}
                onValueChanged={(self) => setEndpointVolume(endpoint, self.get_value())}
              />
              <label
                class="volume-device-percent"
                label={volume.as((value) => `${Math.round(value * 100)}%`)}
                xalign={1}
              />
            </box>
          </box>
        );
      }}
    </For>
  );
}

export default function VolumePopover({ open, flip }: VolumePopoverProps) {
  const showNoOutputs = speakers.as((list) => list.length === 0);
  const showNoInputs = microphones.as((list) => list.length === 0);

  return (
    <WidgetPopover popoverClass="volume-popover" menuClassName="volume-menu" open={open} flip={flip}>
      <box class="volume-section volume-section-outputs" orientation={Gtk.Orientation.VERTICAL} spacing={0}>
        <PopoverTitleBlock
          containerClass="volume-header"
          titleClass="volume-header-title"
          title="Audio Outputs"
        />
        <PopoverEmptyState className="volume-empty" visible={showNoOutputs} label="No outputs" />
        <EndpointList endpoints={speakers} />
      </box>
      <box class="volume-section volume-section-inputs" orientation={Gtk.Orientation.VERTICAL} spacing={0}>
        <PopoverTitleBlock
          containerClass="volume-header"
          titleClass="volume-header-title"
          title="Audio Inputs"
        />
        <PopoverEmptyState className="volume-empty" visible={showNoInputs} label="No inputs" />
        <EndpointList endpoints={microphones} />
      </box>
    </WidgetPopover>
  );
}
