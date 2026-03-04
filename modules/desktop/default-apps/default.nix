{
  useDefaultApps = {  }: { username, ... }: {
    home-manager.users.${username}.xdg.mimeApps.enable = true;
  };
  useFirefox = import ./firefox.nix;
  useHaruna = import ./haruna.nix;
  useKitty = import ./kitty.nix;
  useLibreOffice = import ./libreoffice.nix;
  usePeaZip = import ./peazip.nix;
  useVscode = import ./vscode.nix;
}
