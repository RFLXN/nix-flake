{ modules, ... }: {
  imports =
    (with modules.hardware; [
      (useAmdGpu { enableOverdrive = true; })
      (useBluetooth {})
      (useGraphics {})
    ])
    ++ (with modules.system; [
      (boot.useEfiBoot { canTouchEfiVariables = true; })
      (boot.useLanzaboote {})
      (boot.usePlymouth {})
      (boot.useSystemdBoot { configurationLimit = 10; })
      (nix.useCache {})
      (nix.useExperimentalFeatures {})
      (nix.useGc { dates = "Wed 05:00"; })
      (nix.useOptimise { dates = [ "Wed 05:00" ]; })
      (nix.useUnfreePackage {})
      (useCjkFonts {})
      (useFcitx5 {})
      (useImpermanence { rootUuid = "78b6199d-0161-42e2-9dbd-34c69d72d54e"; })
      (useMe { hashedPasswordFile = "/persist/secrets/rflxn.hashedPassword"; })
      (useNetworkManager { useWifi = true; })
      (useZram {})
    ]);
}
