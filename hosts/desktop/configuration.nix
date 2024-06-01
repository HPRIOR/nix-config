{
  config,
  pkgs,
  inputs,
  settings,
  ...
}: let
  userName = settings.userName;
  homeDir = settings.homeDir;
  configDir = settings.configDir;
  defaultLocale = "en_GB.UTF-8";
in {
  imports = [
    ./hardware-configuration.nix
  ];

  hardware.opengl = {
    enable = pkgs.lib.mkDefault true;
    driSupport = true;
    driSupport32Bit = true;
  };

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = settings.hostName; # Define your hostname.

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/London";

  # Select internationalisation properties.
  i18n.defaultLocale = defaultLocale;

  i18n.extraLocaleSettings = {
    LC_ADDRESS = defaultLocale;
    LC_IDENTIFICATION = defaultLocale;
    LC_MEASUREMENT = defaultLocale;
    LC_MONETARY = defaultLocale;
    LC_NAME = defaultLocale;
    LC_NUMERIC = defaultLocale;
    LC_PAPER = defaultLocale;
    LC_TELEPHONE = defaultLocale;
    LC_TIME = defaultLocale;
  };

  # Configure keymap in X11
  services.xserver = {
    videoDrivers = ["nvidia"];
    xkb = {
      variant = "";
      options = "caps:swapescape";
      layout = "gb";
    };
  };

  services.blueman.enable = true;

  # Not sure this works as expected. Still get tty login, but launched hyprland after so I'm happy with it for now
  services.greetd = {
    enable = true;
    settings = rec {
      initial_session = {
        command = "${pkgs.greetd.greetd}/bin/agreety --cmd ${pkgs.hyprland}/bin/Hyprland";
        user = userName;
      };
      default_session = initial_session;
    };
  };

  console.useXkbConfig = true;

  users.users.${settings.userName} = {
    isNormalUser = true;
    uid = settings.uid;
    description = settings.fullName;
    extraGroups = settings.extraGroups;
    packages = with pkgs; [];
  };

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    # standard stuff
    vim
    wget
    git

    # hyprland and wm stuff
    waybar
    (waybar.overrideAttrs (oldAttrs: {
      mesonFlags = oldAttrs.mesonFlags ++ ["-Dexperimental=true"];
    }))

    libnotify
    rofi-wayland
    wl-clipboard
    wlr-randr
    cliphist
    wl-clip-persist
    kdePackages.qtwayland
  ];

  environment.shells = with pkgs; [zsh];
  users.defaultUserShell = pkgs.zsh;

  programs.zsh = {
    enable = true;
  };

  programs.hyprland = {
    enable = true;
  };

  xdg.portal.enable = true;
  xdg.portal.extraPortals = [pkgs.xdg-desktop-portal-gtk];

  sound.enable = true;
  security.rtkit.enable = true;
  # security.polkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  services.mullvad-vpn = {
    enable = true;
    package = pkgs.mullvad-vpn;
  };

  virtualisation.docker.enable = true;

  fileSystems."${settings.homeDir}/Mnt/server-nfs" = {
    device = "home.server.com:/export/Root";
    fsType = "nfs";
    options = ["x-systemd.automount" "noauto" "x-systemd.idle-timeout=1200" "nfsvers=4.2"];
  };

  networking.firewall.enable = true;
  # syncthing for others
  networking.firewall.allowedTCPPorts = [8384 22000 80 443 1401];
  networking.firewall.allowedUDPPorts = [22000 21027 53 1194 1195 1196 1197 1300 1301 1302 1303 1400];

  system.stateVersion = "23.11"; # Did you read the comment? (doesn't need to change?)
  nix.settings.experimental-features = ["nix-command" "flakes"];
}
