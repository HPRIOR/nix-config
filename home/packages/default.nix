{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: let
  cfg = config.my.features;
  isLinux = pkgs.stdenv.isLinux;
  isDarwin = pkgs.stdenv.isDarwin;

  basePackages = with pkgs; [
    aichat
    atool
    bat
    bottom
    choose
    claude-code
    codex
    croc
    ctop
    delta
    difftastic
    duf
    dust
    eva
    eza
    fd
    fzf
    gh
    glances
    glow
    gnupg
    gping
    hexyl
    hurl
    hyperfine
    iftop
    immich-cli
    inetutils
    jless
    jq
    lazydocker
    lazygit
    lsof
    mosh
    nerd-fonts.fira-code
    nerd-fonts.jetbrains-mono
    pay-respects
    perl538Packages.vidir
    procs
    progress
    ripgrep
    sd
    sops
    syncthing
    tetex
    tldr
    tree
    unzip
    watchexec
    zathura
    zoxide
  ];

  largePackages = with pkgs; [
    discord
    spotify
    texstudio
  ];

  linuxBasePackages = with pkgs; [
    _1password-cli
    _1password-gui
    citrix_workspace
    kdePackages.dolphin
    feh
    firefox
    glibc
    grim
    hyprshot
    inputs.ghostty.packages.${pkgs.stdenv.hostPlatform.system}.default
    libtree
    nfs-utils
    papirus-icon-theme
    pavucontrol
    protonmail-bridge
    slurp
    strace
    v4l-utils
    vlc
  ];

  largeLinuxPackages = with pkgs; [
    (zoom-us.overrideAttrs (_oldAttrs: rec {
      version = "6.0.12.5501";
      src = pkgs.fetchurl {
        url = "https://zoom.us/client/${version}/zoom_x86_64.pkg.tar.xz";
        sha256 = "sha256-h9gjVd7xqChaoC2BZWEhR5WdyfQrPiBjM2WHXMgp8uQ=";
      };
    }))
    calibre
    freecad
    libreoffice
    obsidian
    rustdesk
  ];

  darwinBasePackages = with pkgs; [
    zoom-us
  ];

  darwinLargePackages = with pkgs; [];
in {
  config = {
    home.packages =
      basePackages
      ++ lib.optionals cfg.largePackages.enable largePackages
      ++ lib.optionals isLinux linuxBasePackages
      ++ lib.optionals isDarwin darwinBasePackages
      ++ lib.optionals (isLinux && cfg.largePackages.enable) largeLinuxPackages
      ++ lib.optionals (isDarwin && cfg.largePackages.enable) darwinLargePackages;
  };
}
