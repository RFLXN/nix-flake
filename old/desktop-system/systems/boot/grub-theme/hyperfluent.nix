{ pkgs, variant ? "nixos" }:

pkgs.stdenv.mkDerivation {
  pname = "hyperfluent-grub-theme-${variant}";
  version = "1.0.1";

  src = pkgs.fetchFromGitHub {
    owner = "Coopydood";
    repo = "HyperFluent-GRUB-Theme";
    rev = "50a69ef1c020d1e4e69a683f6f8cf79161fb1a92";  # Latest commit
    sha256 = "sha256-l6oZqo6ATv9DWUKAe3fgx3c12SOX0qaqfwd3ppcdUZk=";
  };

  installPhase = ''
    runHook preInstall

    # Create output directory
    mkdir -p $out

    # Copy the selected variant
    if [ -d "${variant}" ]; then
      cp -r ${variant}/* $out/
    else
      echo "Error: Variant '${variant}' not found"
      exit 1
    fi

    runHook postInstall
  '';

  meta = with pkgs.lib; {
    description = "HyperFluent GRUB Theme - ${variant} variant";
    homepage = "https://github.com/Coopydood/HyperFluent-GRUB-Theme";
    platforms = platforms.linux;
  };
}
