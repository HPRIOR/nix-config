{
  pkgs,
  settings,
  linuxSettings,
  config,
  lib,
  ...
}: let
  isLinux = pkgs.stdenv.isLinux;
  foregroundColour = "#${config.colorScheme.palette.base05}";
  backgroundColour = "#${config.colorScheme.palette.base02}";
  progressColour = "#${config.colorScheme.palette.base0A}";
in
  lib.mkIf isLinux {
    services.dunst.enable = true;
    services.dunst.iconTheme = {
      name = "papirus-icon-theme";
      package = pkgs.papirus-icon-theme;
    };
    services.dunst.settings = {
      global = {
        alignment = "left";
        browser = "${pkgs.firefox}/bin/firefox";
        corner_radius = 10;
        ellipsize = "end";
        follow = "none";
        font = settings.font;
        frame_color = "#${config.colorScheme.palette.base0D}";
        frame_width = 2;
        gap_size = 5;
        height = 1000;
        history_length = 20;
        horizontal_padding = 10;
        icon_corner_radius = 5;
        icon_position = "left";
        markup = "full";
        max_icon_size = 128;
        min_icon_size = 32;
        monitor = "${linuxSettings.primaryMonitor}";
        mouse_left_click = "do_action, close_current";
        mouse_middle_click = "close_current";
        mouse_right_click = "close_all";
        offset = "15x15";
        origin = "top-right";
        padding = 10; # vertical padding
        progress_bar = true;
        progress_bar_corner_radius = 2;
        scale = 0;
        separator_color = "auto";
        show_indicators = "yes";
        sort = "yes";
        stack_duplicates = true;
        text_icon_padding = 10;
        transparency = 10;
        width = "(300, 1000)";
      };

      urgency_normal = {
        frame_color = "#${config.colorScheme.palette.base03}";
        background = backgroundColour;
        foreground = foregroundColour;
        highlight = progressColour;
        timeout = 10;
      };

      urgency_low = {
        frame_color = "#${config.colorScheme.palette.base0B}";
        background = backgroundColour;
        foreground = foregroundColour;
        highlight = progressColour;
        timeout = 10;
      };

      urgency_critical = {
        frame_color = "#${config.colorScheme.palette.base08}";
        background = backgroundColour;
        foreground = foregroundColour;
        highlight = progressColour;
        timeout = 10;
      };
    };
  }
