{ modules, ... }: {
  imports = with modules.programs; [
    (gaming.useLsfgVk {})
    (gaming.useProtonplus {})
    (gaming.useR2modman {})
    (gaming.useSteam { enableGamescope = true; })
    (gaming.useWine { isWayland = true; })
    (jetbrains.useIntellij { enableZshAlias = true; })
    (jetbrains.useWebstorm { enableZshAlias = true; })
    (shell.useShell {})
    (shell.useZsh {})
    (useAyugram {})
    (useBlueman {})
    (useClaudeCode {})
    (useCodex {})
    (useCommonTools {})
    (useDirenv {})
    (useDiscord {})
    (useDolphin {})
    (useFastfetch {
      beforeModules = [
        { type = "custom"; format = "RFLXN's Desktop"; outputColor = "light_green"; }
        { type = "custom"; format = "https://github.com/RFLXN/nix-flake"; outputColor = "dim_white"; }
      ];
    })
    (useFirefox {})
    (useGit { name = "RFLXN"; email = "solid2113@naver.com"; })
    (useHaruna {})
    (useHyprshot {})
    (useKcalc { enableWindowsAlias = true; })
    (useKitty {})
    (useKolourpaint { enableWindowsAlias = true; })
    (useLact {})
    (useLibreOffice {})
    (useNixIndex {})
    (useNmApplet {})
    (useObsStudio {})
    (usePeaZip {})
    (usePwvucontrol {})
    (useSpotify {})
    (useThunar {})
    (useVscode {})
    (useWaylandUtils {})
  ];
}
