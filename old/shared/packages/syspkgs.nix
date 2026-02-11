{ pkgs, lib, ... }: {
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    vim
    nano

    git
    git-lfs
    gh

    zsh
    zsh-powerlevel10k

    claude-code

    tailscale

    # network tools
    bind          # dig, nslookup, host

    # system monitoring
    htop
    lsof          # list open files

    # file utilities
    tree          # directory visualization
    rsync         # file sync
    file          # file type detection
    curl
    wget

    # archive tools
    unzip         # zip extraction
    zip           # zip creation

    # text processing
    ripgrep       # rg - better grep
    jq            # JSON processor
    yq
    less          # pager
  ] ++ lib.optionals pkgs.stdenv.isLinux [
    # Linux-only packages
    iproute2      # ip, ss (modern networking)
    net-tools     # ifconfig, netstat (legacy but familiar)
    procps        # ps, top, free, vmstat, uptime
    iotop         # I/O monitoring
    parted        # partition management
    smartmontools # disk health monitoring
  ];
}