{
  pkgs,
  lib,
  ...
}: let
  isLinux = pkgs.stdenv.isLinux;
in
  lib.mkIf isLinux {
    services.dunst.enable = lib.mkForce false;

    programs.noctalia-shell.settings.notifications = {
      enabled = true;
      location = "top_right";
    };
  }
