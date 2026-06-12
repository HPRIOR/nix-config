{
  pkgs,
  lib,
  ...
}: let
  isLinux = pkgs.stdenv.isLinux;
in
  lib.mkIf isLinux {
    services.dunst.enable = lib.mkForce false;

    programs.noctalia.settings.notification = {
      enable_daemon = true;
      layer = "top";
    };
  }
