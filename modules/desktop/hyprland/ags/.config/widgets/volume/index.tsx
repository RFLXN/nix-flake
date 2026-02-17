import AstalWp from "gi://AstalWp?version=0.1";
import { Accessor } from "gnim";
import { LabeledWidgetButton } from "../../components/outer";
import VolumePopover from "./popover";

const ICONS = {
  muted: "󰖁",
  unmuted: "󰕾",
} as const;

const wp = AstalWp.Wp.get_default();

type VolumeState = {
  available: boolean;
  muted: boolean;
  volume: number;
};

const emptyState: VolumeState = { available: false, muted: true, volume: 0 };

const volumeState = wp
  ? new Accessor<VolumeState>(
      () => {
        const speaker = wp.defaultSpeaker;
        if (!speaker) return { ...emptyState };
        const muted =
          typeof speaker.mute === "boolean"
            ? speaker.mute
            : typeof speaker.get_mute === "function"
              ? speaker.get_mute()
              : false;
        const volume =
          typeof speaker.volume === "number"
            ? speaker.volume
            : typeof speaker.get_volume === "function"
              ? speaker.get_volume()
              : 0;
        return { available: true, muted, volume };
      },
      (notify) => {
        let speaker = wp.defaultSpeaker;
        let speakerId: number | null = null;
        let volumeId: number | null = null;

        const attachSpeaker = () => {
          if (speaker && speakerId !== null) {
            speaker.disconnect(speakerId);
          }
          if (speaker && volumeId !== null) {
            speaker.disconnect(volumeId);
          }
          speaker = wp.defaultSpeaker;
          speakerId = null;
          volumeId = null;
          if (speaker) {
            speakerId = speaker.connect("notify::mute", () => notify());
            volumeId = speaker.connect("notify::volume", () => notify());
          }
          notify();
        };

        const wpId = wp.connect("notify::default-speaker", () => attachSpeaker());
        attachSpeaker();

        return () => {
          if (speaker && speakerId !== null) speaker.disconnect(speakerId);
          if (speaker && volumeId !== null) speaker.disconnect(volumeId);
          wp.disconnect(wpId);
        };
      },
    )
  : new Accessor<VolumeState>(() => ({ ...emptyState }), () => () => {});

export default function Volume() {
  const label = volumeState.as((state) => {
    if (!state.available) return `${ICONS.muted} --%`;
    const volumePercent = Math.round(state.volume * 100);
    const icon = state.muted ? ICONS.muted : ICONS.unmuted;
    return `${icon} ${volumePercent}%`;
  });
  const toggleMute = () => {
    if (!wp) return;
    const speaker = wp.defaultSpeaker;
    if (!speaker) return;
    const muted =
      typeof speaker.mute === "boolean"
        ? speaker.mute
        : typeof speaker.get_mute === "function"
          ? speaker.get_mute()
          : false;
    if (typeof speaker.set_mute === "function") {
      speaker.set_mute(!muted);
    } else {
      speaker.mute = !muted;
    }
  };

  return (
    <LabeledWidgetButton
      className="volume"
      child={<label label={label} />}
      onSecondaryClick={toggleMute}
      menu={(menu) => <VolumePopover open={menu.open} flip={menu.flip} />}
    />
  );
}
