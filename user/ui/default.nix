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
        modules-left = ["hyprland/workspaces" "hyprland/submap"];
        modules-center = ["hyprland/window"];
        modules-right = ["disk" "cpu" "tray" "clock"];
        "hyprland/workspaces" = {
          all-outputs = true;
        };
        "hyprland/window" = {
          format = "{title}";
          max-length = 50;
          rewrite = {
            "(.*) — Mozilla Firefox" = "🌎 $1";
          };
        };
      };
    };
    style = ''
      * {
          background: #${config.colorScheme.palette.base01};
          border: none;
          border-radius: 0;
          font-family: ${userSettings.font};
          font-size: 13px;
          min-height: 0;
      }

    '';
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
      monitor=DP-2,2560x2880@29.969999,3440x0,1.333333
      monitor=DP-1,3840x2160,-1440x-400,1.5,transform,1
      monitor=,preferred,auto,1
      monitor=HDMI-A-1,disable

      workspace=1,monitor:DP-1,default:true
      workspace=2,monitor:DP-3,defualt:true
      workspace=3,monitor:DP-2,default:true

      # Key bindings
      $mainMod = SUPER
      $shiftMod = SUPERSHIFT
      bind = $mainMod, Return, exec, kitty
      bind = $shiftMod, Q, killactive

      bind = $mainMod, H, movefocus, l
      bind = $mainMod, J, movefocus, d
      bind = $mainMod, K, movefocus, u
      bind = $mainMod, L, movefocus, r

      bind = $shiftMod, H, movewindoworgroup, l
      bind = $shiftMod, J, movewindoworgroup, d
      bind = $shiftMod, K, movewindoworgroup, u
      bind = $shiftMod, L, movewindoworgroup, r

      bind = $mainMod, SPACE, exec, rofi -show drun
      bind = $mainMod, F, fullscreen, 0
      bind = $shiftMod, F, togglefloating,

      bind = $mainMod, 1, workspace, 1
      bind = $mainMod, 2, workspace, 2
      bind = $mainMod, 3, workspace, 3
      bind = $mainMod, 4, workspace, 4
      bind = $mainMod, 5, workspace, 5
      bind = $mainMod, 6, workspace, 6
      bind = $mainMod, 7, workspace, 7
      bind = $mainMod, 8, workspace, 8
      bind = $mainMod, 9, workspace, 9
      bind = $shiftMod, 1, movetoworkspace, 1
      bind = $shiftMod, 2, movetoworkspace, 2
      bind = $shiftMod, 3, movetoworkspace, 3
      bind = $shiftMod, 4, movetoworkspace, 4
      bind = $shiftMod, 5, movetoworkspace, 5
      bind = $shiftMod, 6, movetoworkspace, 6
      bind = $shiftMod, 7, movetoworkspace, 7
      bind = $shiftMod, 8, movetoworkspace, 8
      bind = $shiftMod, 9, movetoworkspace, 9

      bind = $mainMod, G, togglegroup
      bind = $mainMod,bracketleft,changegroupactive,b
      bind = $mainMod,bracketright,changegroupactive,f

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

      # Switch to submap called move
      bind=$mainMod,M,submap,move

      submap=move
      binde=,L,moveactive,30 0
      binde=,H,moveactive,-30 0
      binde=,K,moveactive,0 -30
      binde=,J,moveactive,0 30

      # use reset to go back to the global submap
      bind=,escape,submap,reset
      bind=$mainMod,M,submap,reset
      bind=,return,submap,reset

      # Reset submap, normal keybindings resume
      submap=reset


      general {
        gaps_out = 5
        gaps_in = 5
        resize_on_border = true
        border_size = 2
        col.active_border = 0x${config.colorScheme.palette.base0E}ff 0x${config.colorScheme.palette.base0F}ff 45deg
        col.inactive_border = 0x${config.colorScheme.palette.base02}ff 0x${config.colorScheme.palette.base03}ff 90deg

      }
      group {
        col.border_active = 0x${config.colorScheme.palette.base0E}ff 0x${config.colorScheme.palette.base0F}ff 45deg
        col.border_inactive = 0x${config.colorScheme.palette.base02}ff 0x${config.colorScheme.palette.base03}ff 90deg
        groupbar {
            font_family = "${userSettings.font}"
            font_size = 10
            height = 16
            col.active = 0x${config.colorScheme.palette.base0F}ff
            col.inactive = 0x${config.colorScheme.palette.base02}ff
        }
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
