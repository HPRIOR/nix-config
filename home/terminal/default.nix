{
  pkgs,
  config,
  settings,
  inputs,
  lib,
  ...
}: let
  cfg = config.my.features.ghostty;
in {
  config = lib.mkIf cfg.enable {
    home.sessionVariables = {
      TERMCMD =
        if pkgs.stdenv.isLinux
        then "${inputs.ghostty.packages.${pkgs.stdenv.hostPlatform.system}.default}/bin/ghostty"
        else "ghostty";
    };

    home.file."${settings.configDir}/ghostty/config".text = let
      base = ''
        font-family = ${settings.font}
        theme = Kanagawabones
        gtk-titlebar = false
      '';
      linuxConfig = ''
        async-backend = epoll
        gtk-single-instance = true
      '';
    in
      if pkgs.stdenv.isLinux
      then base + linuxConfig
      else base;
  };
}
