{ lib }:
let
  toLua = lib.generators.toLua {};
  lua = lib.generators.mkLuaInline;

  keyFromHyprlang = key:
    let
      parts = map lib.strings.trim (lib.splitString "," key);
      mods = if parts == [] then "" else builtins.elemAt parts 0;
      keyName = if builtins.length parts >= 2 then builtins.elemAt parts 1 else key;
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
in {
  inherit lua toLua keyFromHyprlang;

  bind = key: dispatcher: {
    _args = [
      (keyFromHyprlang key)
      (lua dispatcher)
    ];
  };

  inherit bindWith;

  execBind = key: command:
    (bindWith key "hl.dsp.exec_cmd(${toLua command})" {});

  execBindWith = key: command: opts:
    bindWith key "hl.dsp.exec_cmd(${toLua command})" opts;

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
