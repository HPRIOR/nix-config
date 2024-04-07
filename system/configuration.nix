# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  config,
  pkgs,
  inputs,
  systemSettings,
  userSettings,
  ...
}: let
  userName = userSettings.userName;
  homeDir = userSettings.homeDir;
  configDir = userSettings.configDir;
in {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    inputs.sops-nix.nixosModules.sops
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

  networking.hostName = systemSettings.networkHostName; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/London";

  # Select internationalisation properties.
  i18n.defaultLocale = systemSettings.defaultLocale;

  i18n.extraLocaleSettings = {
    LC_ADDRESS = systemSettings.defaultLocale;
    LC_IDENTIFICATION = systemSettings.defaultLocale;
    LC_MEASUREMENT = systemSettings.defaultLocale;
    LC_MONETARY = systemSettings.defaultLocale;
    LC_NAME = systemSettings.defaultLocale;
    LC_NUMERIC = systemSettings.defaultLocale;
    LC_PAPER = systemSettings.defaultLocale;
    LC_TELEPHONE = systemSettings.defaultLocale;
    LC_TIME = systemSettings.defaultLocale;
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


  # Configure console keymap
  # console.keyMap = "uk";
  console.useXkbConfig = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.${userSettings.userName} = {
    isNormalUser = true;
    uid = userSettings.uid;
    description = userSettings.fullName;
    extraGroups = userSettings.extraGroups;
    packages = with pkgs; [];
  };

  # Enable automatic login for the user.
  ## services.getty.autologinUser = "harryp";

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
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
    dunst
    libnotify
    rofi-wayland
    wl-clipboard
    wlr-randr
  ];
  # secrets management. Needs to run in sys config for now because templates aren't supported
  sops = {
    defaultSopsFile = ../secrets/secrets.yaml;
    defaultSopsFormat = "yaml";
    age = {
      # Private key generated using ssh and `nix run nixpkgs#ssh-to-age -- -private-key -i ~/.ssh/private > ~/.config/sops/age/keys.txt`
      keyFile = "/etc/sops/age/keys.txt";
    };
    secrets.gpt-api-key = {
      owner = config.users.users.${userName}.name;
    };
  };

  environment.shells = with pkgs; [zsh];
  users.defaultUserShell = pkgs.zsh;

  programs.zsh = {
    enable = true;
    shellInit = ''
      export OPENAI_API_KEY=$(cat ${config.sops.secrets.gpt-api-key.path})
    '';
  };

  programs.hyprland = {
    enable = true;
  };

  xdg.portal.enable = true;
  xdg.portal.extraPortals = [pkgs.xdg-desktop-portal-gtk];

  sound.enable = true;
  security.rtkit.enable = true;
  security.polkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  programs._1password.enable = true;
  programs._1password-gui = {
    enable = true;
    # Certain features, including CLI integration and system authentication support,
    # require enabling PolKit integration on some desktop environments (e.g. Plasma).
    polkitPolicyOwners = [userSettings.fullName];
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  services.syncthing = {
    user = userName;
    dataDir = homeDir;
    configDir = configDir;
    enable = true;
    };

  networking.firewall.allowedTCPPorts = [8384 22000];
  networking.firewall.allowedUDPPorts = [22000 21027];

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?
  nix.settings.experimental-features = ["nix-command" "flakes"];
}
