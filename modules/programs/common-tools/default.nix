{ }:
{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    # System monitoring
    htop
    btop
    iotop
    smartmontools
    lm_sensors
    dmidecode

    # Search & text processing
    ripgrep
    fd            # find alternative
    jq
    yq
    fzf           # fuzzy finder

    # Modern CLI replacements
    bat           # cat alternative
    eza           # ls alternative
    dust          # du alternative
    duf           # df alternative
    sd            # sed alternative

    # File utilities
    tree
    rsync
    file
    less
    unzip
    zip
    ncdu          # disk usage analyzer

    # Network utilities
    bind          # dig, nslookup
    curl
    wget
    net-tools

    # System utilities
    iproute2      # ip, ss
    procps        # ps, top, vmstat
    parted
    pciutils      # lspci
    usbutils      # lsusb

    # Terminal tools
    tmux
    tldr          # simplified man pages

    # Editors
    nano
    vim

    # Classic Unix tools (busybox-style)
    gawk          # awk
    gnused        # sed
    gnugrep       # grep
    gnutar        # tar
    findutils     # find, xargs, locate
    diffutils     # diff, cmp, diff3
    which
    bc            # calculator

    # Compression
    gzip
    bzip2
    xz
    zstd
    p7zip         # 7z

    # Debug & inspection
    lsof
    strace
    ltrace
    hexdump
    dos2unix
  ];
}
