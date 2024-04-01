# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  config,
  pkgs,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
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

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/London";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_GB.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_GB.UTF-8";
    LC_IDENTIFICATION = "en_GB.UTF-8";
    LC_MEASUREMENT = "en_GB.UTF-8";
    LC_MONETARY = "en_GB.UTF-8";
    LC_NAME = "en_GB.UTF-8";
    LC_NUMERIC = "en_GB.UTF-8";
    LC_PAPER = "en_GB.UTF-8";
    LC_TELEPHONE = "en_GB.UTF-8";
    LC_TIME = "en_GB.UTF-8";
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
  users.users.harryp = {
    isNormalUser = true;
    description = "Harry Prior";
    extraGroups = ["networkmanager" "wheel"];
    packages = with pkgs; [
      ranger
      croc

      # hyprland stuff
      waybar
      (waybar.overrideAttrs (oldAttrs: {
        mesonFlags = oldAttrs.mesonFlags ++ ["-Dexperimental=true"];
      }))
      dunst
      libnotify
      rofi-wayland
      wlr-randr
      wl-clipboard
      nwg-displays

      # modern unix apps
      eza # ls replacement
      lazygit
      lazydocker
      difftastic
      bat # cat replacement
      du-dust # intuitive du - view drive space
      duf
      fd # find alternative
      ripgrep
      fzf
      choose # user friendly cut (and awk)
      jq # json processor
      sd # sed alternative
      tldr
      bottom
      glances
      hyperfine # benchmarking tool
      gping # ping with graph
      procs # ps alternative
      zoxide

      # git syntax highlighting pager
      delta

      # terminal emulator
      kitty

      # applications
      firefox

      # rust
      cargo
      rustc
      gcc
    ];
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
  ];

  environment.shells = with pkgs; [zsh];
  users.defaultUserShell = pkgs.zsh;
  programs.zsh.enable = true;

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
    polkitPolicyOwners = ["Harry Prior"];
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
