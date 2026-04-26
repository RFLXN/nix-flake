{ modules, ... }: {
  imports = with modules.programs; [
    (gaming.useLsfgVk {})
    (gaming.useLutris {})
    (gaming.useMangoHud {
      settings = {
        fps = true;
        frametime = false;
        gpu_stats = false;
        cpu_stats = false;
        ram = false;
        vram = false;
      };
    })
    (gaming.useProtonplus {})
    (gaming.useR2modman {})
    (gaming.useSteam { enableGamescope = true; enableProtontricks = true; })
    (gaming.useWine { isWayland = true; })
    (jetbrains.useIntellij { enableZshAlias = true; })
    (jetbrains.useWebstorm { enableZshAlias = true; })
    (shell.useShell {})
    (shell.useZsh {})
    (useAyugram {})
    (useBlueman {})
    (useClaudeCode {})
    (useCodex {})
    (useCodexDesktop {})
    (useCommonTools {})
    (useChrome {})
    (useDirenv {})
    (useDiscord {})
    (useDolphin {})
    (useFastfetch {
      beforeModules = [
        { type = "custom"; format = "RFLXN's Desktop"; outputColor = "light_green"; }
        { type = "custom"; format = "https://github.com/RFLXN/nix-flake"; outputColor = "dim_white"; }
      ];
    })
    (useForgeCode { enableZshIntegration = true; })
    (useFirefox {})
    (useGit { name = "RFLXN"; email = "solid2113@naver.com"; })
    (useHaruna {})
    (useHyprshot {})
    (useKcalc { enableWindowsAlias = true; })
    (useKitty {})
    (useKolourpaint { enableWindowsAlias = true; })
    (useLact {})
    (useLibreOffice {})
    (useMoonlight {})
    (useNixIndex {})
    (useNmApplet {})
    (useObsStudio {})
    (usePeaZip {})
    (usePwvucontrol {})
    (useShotcut {})
    (useSpotify {})
    (useT3 {})
    (useThunar {})
    (useVscode {})
    (useWaylandUtils {})
  ];
}
