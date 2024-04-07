{pkgs, ...}: {
  home.sessionVariables = {
    TERMCMD = "${pkgs.kitty}/bin/kitty";
  };
  programs.kitty = {
    enable = true;
    font = {
      name = "FiraCode Nerd Font Mono";
      package = pkgs.nerdfonts.override {fonts = ["FiraCode"];};
      size = 12;
    };
    # theme = "kanagawabones";
    shellIntegration.enableZshIntegration = true;
    settings = {
      # Kanagawa theme
      background = "#1F1F28";
      foreground = "#DCD7BA";
      selection_background = "#2D4F67";
      selection_foreground = "#C8C093";
      url_color = "#72A7BC";
      cursor = "#C8C093";
      active_tab_background = "#1F1F28";
      active_tab_foreground = "#C8C093";
      inactive_tab_background = "#1F1F28";
      inactive_tab_foreground = "#727169";
      color0 = "#16161D";
      color1 = "#C34043";
      color2 = "#76946A";
      color3 = "#C0A36E";
      color4 = "#7E9CD8";
      color5 = "#957FB8";
      color6 = "#6A9589";
      color7 = "#C8C093";
      color8 = "#727169";
      color9 = "#E82424";
      color10 = "#98BB6C";
      color11 = "#E6C384";
      color12 = "#7FB4CA";
      color13 = "#938AA9";
      color14 = "#7AA89F";
      color15 = "#DCD7BA";
      color16 = "#FFA066";
      color17 = "#FF5D62";
      term = "xterm-256color";
    };
    keybindings = {
      "f1" = "new_tab_with_cwd";
    };
  };
}
