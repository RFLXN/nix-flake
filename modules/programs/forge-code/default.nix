{ enableZshIntegration ? false }:
{ pkgs, lib, username, config, ... }:
let
  forgeCodePackage = pkgs.callPackage ./pkg.nix { };
  forgeBin = lib.getExe forgeCodePackage;
in {
  environment.systemPackages = [
    forgeCodePackage
    pkgs.fzf
    pkgs.bat
    pkgs.fd
  ];

  home-manager.users.${username} = {
    home.sessionVariables.FORGE_BIN = forgeBin;

    home.activation.cleanupForgeCodeInstaller = config.home-manager.users.${username}.lib.dag.entryAfter [ "writeBoundary" ] ''
      installer_marker='# Added by ForgeCode installer'
      installer_path_line="export PATH=\"$HOME/.local/bin:\$PATH\""

      if [ -e "$HOME/.local/bin/forge" ] && [ ! -L "$HOME/.local/bin/forge" ]; then
        rm -f "$HOME/.local/bin/forge"
      fi

      for rc_file in "$HOME/.bashrc"; do
        if [ ! -f "$rc_file" ]; then
          continue
        fi

        if ! grep -Fqx "$installer_marker" "$rc_file" && ! grep -Fqx "$installer_path_line" "$rc_file"; then
          continue
        fi

        tmp_rc="$(mktemp)"
        ${pkgs.gawk}/bin/awk -v marker="$installer_marker" -v path_line="$installer_path_line" '
          $0 != marker && $0 != path_line
        ' "$rc_file" > "$tmp_rc"
        cat "$tmp_rc" > "$rc_file"
        rm -f "$tmp_rc"
      done
    '';
  } // lib.optionalAttrs enableZshIntegration {
    programs.zsh.initContent = lib.mkAfter ''
      # ForgeCode must load before zsh-syntax-highlighting.
      if [[ -x ${forgeBin} ]]; then
        eval "$(${forgeBin} zsh plugin 2>/dev/null || true)"
        eval "$(${forgeBin} zsh theme 2>/dev/null || true)"
      fi
    '';
  };
}
