{
  config,
  userSettings,
  ...
}: {
  programs.waybar = {
    enable = true;
    settings = {
      mainBar = {
        height = 10;
        output = "DP-3";
        reload_style_on_change = true;
        modules-left = ["hyprland/workspaces"];
        modules-right = ["tray"];
        "hyprland/workspaces" = {
          all-outputs = true;
        };
      };
    };
  };
  wayland.windowManager.hyprland = {
    enable = true;
    extraConfig = ''
      # Required for mouse to render
      env = WLR_NO_HARDWARE_CURSORS,1

      # Startup applications
      exec-once = waybar
      exec-once = blueman-applet

      # Monitor
      monitor=DP-3,3440x1440@74.983002,0x0,1
      monitor=DP-2,2560x2880@29.969999,3440x0,1
      monitor=DP-1,3840x2160,-1440x-400,1.5,transform,1
      monitor=,preferred,auto,1
      monitor=HDMI-A-1,disable

      # Key bindings
      $mainMod = SUPER
      $shiftMod = SUPERSHIFT
      bind = $mainMod, Return, exec, kitty
      bind = $shiftMod, Q, killactive

      bind = $mainMod, H, movefocus, l
      bind = $mainMod, J, movefocus, d
      bind = $mainMod, K, movefocus, u
      bind = $mainMod, L, movefocus, r

      bind = $shiftMod, H, movewindow, l
      bind = $shiftMod, J, movewindow, d
      bind = $shiftMod, K, movewindow, u
      bind = $shiftMod, L, movewindow, r

      bind = $mainMod, SPACE, exec, rofi -show drun
      bind = $mainMod, F, fullscreen, 0

      bindm = $mainMod, mouse:272, movewindow
      bindm = $mainMod, mouse:273, resizewindow

      # Switch to submap called resize
      bind=$mainMod,R,submap,resize

      submap=resize
      binde=,L,resizeactive,30 0
      binde=,H,resizeactive,-30 0
      binde=,K,resizeactive,0 -30
      binde=,J,resizeactive,0 30

      # use reset to go back to the global submap
      bind=,escape,submap,reset
      bind=$mainMod,R,submap,reset
      bind=,return,submap,reset

      # Reset submap, normal keybindings resume
      submap=reset

      general {
        gaps_out = 5
        gaps_in = 5
        resize_on_border = true
        border_size = 2
        col.active_border = 0x${config.colorScheme.palette.base0E}ff 0x${config.colorScheme.palette.base09}ff 45deg
        col.inactive_border =0x${config.colorScheme.palette.base02}ff 0x${config.colorScheme.palette.base03}ff 90deg

      }

      input {
          kb_layout = gb
          kb_options = caps:swapescape
      }

      misc {
          disable_splash_rendering = true
          disable_hyprland_logo = true
      }

      decoration {
          rounding = 5
          blur {
              enabled = true
              size = 3
              passes = 1
              vibrancy = 0.1696
          }
          inactive_opacity = 0.95
      }

    '';
  };
}
