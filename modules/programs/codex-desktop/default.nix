{ quitOnClose ? false }:
{ pkgs, username, codex-cli-nix, codex-desktop, ... }:
let
  system = pkgs.stdenv.hostPlatform.system;
  withQuitOnClose =
    package:
    package.overrideAttrs (old: {
      pname = "${old.pname}-quit-on-close";

      nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [
        pkgs.gnugrep
      ];

      postInstall = (old.postInstall or "") + ''
        resources_dir="$out/opt/codex-desktop/resources"
        app_dir="$TMPDIR/codex-desktop-quit-on-close"
        ordering_file="$TMPDIR/codex-desktop-quit-on-close.ordering"

        ${pkgs.asar}/bin/asar extract "$resources_dir/app.asar" "$app_dir"

        target_count="$(
          ${pkgs.gnugrep}/bin/grep -rlF \
            -- 'this.options.canHideLastWindowToTray?.()===!0' "$app_dir" \
            | ${pkgs.coreutils}/bin/wc -l
        )"
        if [ "$target_count" -ne 1 ]; then
          echo "Expected one Codex window lifecycle bundle, found $target_count" >&2
          exit 1
        fi

        target="$(
          ${pkgs.gnugrep}/bin/grep -rlF \
            -- 'this.options.canHideLastWindowToTray?.()===!0' "$app_dir"
        )"
        close_pattern='this\.options\.canHideLastWindowToTray\?\.\(\)===!0&&![A-Za-z_$][A-Za-z0-9_$]*\)\{[A-Za-z_$][A-Za-z0-9_$]*\.preventDefault\(\),[A-Za-z_$][A-Za-z0-9_$]*\.hide\(\);return\}'
        close_implementation_count="$(
          ${pkgs.gnugrep}/bin/grep -oE \
            -- "$close_pattern" "$target" \
            | ${pkgs.coreutils}/bin/wc -l
        )"
        if [ "$close_implementation_count" -ne 1 ]; then
          echo "Expected one Codex final-window close implementation, found $close_implementation_count" >&2
          exit 1
        fi

        close_implementation="$(
          ${pkgs.gnugrep}/bin/grep -oE \
            -- "$close_pattern" "$target"
        )"
        quit_implementation="$(
          printf '%s\n' "$close_implementation" \
            | ${pkgs.gnused}/bin/sed -E \
                -e 's/^this\.options\.canHideLastWindowToTray\?\.\(\)===!0/!0/' \
                -e 's/[A-Za-z_$][A-Za-z0-9_$]*\.hide\(\)/(typeof codexLinuxPrepareForExplicitQuit===`function`?codexLinuxPrepareForExplicitQuit():typeof codexLinuxMarkQuitInProgress===`function`\&\&codexLinuxMarkQuitInProgress()),setImmediate(()=>require(`electron`).app.quit())/'
        )"
        substituteInPlace "$target" \
          --replace-fail "$close_implementation" "$quit_implementation"

        rm -f "$resources_dir/app.asar"
        rm -rf "$resources_dir/app.asar.unpacked"
        (
          cd "$app_dir"
          find . -type f | LC_ALL=C sort | sed 's#^\./##' > "$ordering_file"
        )
        ${pkgs.asar}/bin/asar pack "$app_dir" "$resources_dir/app.asar" \
          --ordering "$ordering_file" \
          --unpack "{*.node,*.so,*.dylib}"
      '';
    });
  codexDesktopPackage =
    if quitOnClose then
      withQuitOnClose codex-desktop.packages.${system}.codex-desktop
    else
      null;
in
{
  home-manager.users.${username} = {
    imports = [
      codex-desktop.homeManagerModules.default
    ];

    programs.codexDesktopLinux = {
      enable = true;
      package = codexDesktopPackage;
      remoteControl.package = codex-cli-nix.packages.${system}.default;
    };
  };
}
