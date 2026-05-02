{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.my.features.desktop.notifications;
  isLinux = pkgs.stdenv.isLinux;
in
  lib.mkIf (isLinux && cfg.enable) {
    services.dunst.enable = lib.mkForce false;

    programs.noctalia-shell.settings.notifications = {
      enabled = true;
      location = "top_right";
    };
  }
