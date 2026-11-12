{ lib }:
let
  toLua = lib.generators.toLua { };
  lua = lib.generators.mkLuaInline;

  # "MODS, key" (Hyprlang style) becomes "MOD + MOD + key". A value without a
  # comma is a bare key with no modifiers.
  keyFromHyprlang =
    key:
    let
      parts = map lib.strings.trim (lib.splitString "," key);
      hasMods = builtins.length parts >= 2;
      mods = if hasMods then builtins.elemAt parts 0 else "";
      keyName = builtins.elemAt parts (if hasMods then 1 else 0);
      modifierParts = builtins.filter (part: part != "") (lib.splitString " " mods);
    in
    lib.concatStringsSep " + " (modifierParts ++ [ keyName ]);

  bindWith = key: dispatcher: opts: {
    _args = [
      (keyFromHyprlang key)
      (lua dispatcher)
      opts
    ];
  };
in
{
  inherit lua toLua keyFromHyprlang;

  bind = key: dispatcher: {
    _args = [
      (keyFromHyprlang key)
      (lua dispatcher)
    ];
  };

  inherit bindWith;

  execBind = key: command: bindWith key "hl.dsp.exec_cmd(${toLua command})" { };

  execBindWith = key: command: opts: bindWith key "hl.dsp.exec_cmd(${toLua command})" opts;

  onStart = commands: {
    _args = [
      "hyprland.start"
      (lua ''
        function()
        ${lib.concatMapStrings (command: "  hl.exec_cmd(${toLua command})\n") commands}end
      '')
    ];
  };
}
