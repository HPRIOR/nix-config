{
  pkgs,
  lib,
  settings,
  ...
}: let
  homeDir = settings.homeDir;
  excludeIp = "192.168.100.60";
  lanInterface = "en0";
  lanGateway = "192.168.1.1";
in {
  environment.systemPackages = [
    pkgs.vim
  ];

  nix.enable = true;
  users.users.harryp.home = lib.mkForce homeDir;
  nix.settings.experimental-features = "nix-command flakes";
  nix.extraOptions = ''
    extra-platforms = x86_64-darwin aarch64-darwin
  '';

  programs.zsh.enable = true; # default shell on catalina

  system = {
    primaryUser = "harryp";
    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToEscape = true;
    };
    stateVersion = 4;
    defaults = {
      dock = {
        mru-spaces = false;
        persistent-apps = [
          # todo
        ];
        autohide = true;
        show-recents = false;
      };

      finder = {
        AppleShowAllExtensions = true;
        FXPreferredViewStyle = "clmv";
      };
      screencapture.location = "~/Pictures/screenshots";
    };
  };

  nixpkgs.hostPlatform = "aarch64-darwin";
  security.pam.services.sudo_local.touchIdAuth = true;

  homebrew = let
    baseCasks = [
      "1password"
      "citrix-workspace"
      "dropbox"
      "ghostty"
      "mullvadvpn"
      "obsidian"
      "protonmail-bridge"
      "rectangle"
      "vlc"
      "whatsapp"
    ];
    largeCasks = [
      "libreoffice"
      "freecad"
      "calibre"
      "mactex"
      "rustdesk"
    ];
    isMinimal = settings.profile == "minimal";
  in {
    enable = true;
    onActivation.autoUpdate = true;
    onActivation.upgrade = true;
    onActivation.cleanup = "uninstall";
    casks = baseCasks ++ lib.optionals (!isMinimal) largeCasks;
  };

  system.activationScripts.pf.text = ''
    echo "configuring pf..." >&2

    pf_anchor="/etc/pf.anchors/nix-darwin"
    pf_conf="/etc/pf.conf"

    cat > "$pf_anchor" <<'EOF'
    exclude_ip = "${excludeIp}"
    lan_if = "${lanInterface}"
    lan_gw = "${lanGateway}"

    # Route excluded IP via LAN to bypass the VPN tunnel.
    pass out quick on $lan_if route-to ($lan_if $lan_gw) to $exclude_ip
    EOF

    if ! /usr/bin/grep -q 'anchor "nix-darwin"' "$pf_conf"; then
      printf '\nanchor "nix-darwin"\nload anchor "nix-darwin" from "/etc/pf.anchors/nix-darwin"\n' >> "$pf_conf"
    fi

    /sbin/pfctl -f "$pf_conf"
    /sbin/pfctl -e 2>/dev/null || true
  '';
}
