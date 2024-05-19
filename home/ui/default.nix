{
  pkgs,
  config,
  settings,
  lib,
  ...
}: let
  isLinux = pkgs.stdenv.isLinux;
  createToggleApp = app: "pgrep ${app} > /dev/null && pkill ${app} || ${app}  & > /dev/null";

  createBarWindowRule = app: verticalSizePercent: horizontalSize: ''
    windowrule=workspace 2,^(${app})$
    windowrule=size ${toString horizontalSize} ${toString verticalSizePercent}%,^(${app})$
    windowrule=move 100%-${toString (horizontalSize + 30)} 50,^(${app})$
    windowrule=float,^(${app})$
    windowrule=animation slide,^(${app})$
  '';

  # Todo create a function that will generate the position of each screan automatically 
  monitorLeft = {
    screen = "DP-1";
    res = "3840x2160";
    hertz = "59.997002";
    pos = "-1440x-400";
    scale = "1.5";
    transform = "1";
  };
  monitorCentre = {
    screen = "HDMI-A-1";
    res = "3440x1440";
    hertz = "74.983002";
    pos = "0x0";
    scale = "1";
    transform = throw "No transform set for monitor centre";
  };
  monitorRight = {
    screen = "DP-2";
    res = "2560x2880";
    hertz = "59.966999";
    pos = "3440x0";
    scale = "1.333333";
    transform = throw "No transform set for monitor centre";
  };
in {
  imports = [
    ./rofi.nix
    ./notifications.nix
  ];

  programs.waybar = {
    enable = isLinux;
    settings = {
      mainBar = {
        height = 20;
        spacing = 4;
        margin-top = 5;
        margin-bottom = 1;
        margin-right = 6;
        margin-left = 6;
        output = monitorCentre.screen;
        reload_style_on_change = true;
        modules-left = ["hyprland/workspaces" "hyprland/submap"];
        modules-right = ["tray" "pulseaudio" "disk#root" "disk#home" "memory" "cpu" "temperature" "network" "clock"];
        "hyprland/workspaces" = {
          all-outputs = true;
          show-special = true;
        };
        "cpu" = {
          interval = 1;
          format = "{icon} {usage:02}% {avg_frequency:.2f}GHz";
          format-icons = ["▁" "▂" "▃" "▄" "▅" "▆" "▇" "█"];
        };
        "temperature" = {
          hwmon-path-abs = "/sys/devices/pci0000:00/0000:00:18.3/hwmon";
          input-filename = "temp1_input";
          critical-threshold = 80;
          format = "{icon} {temperatureC:02}°C";
          format-critical = "󰸁 {temperatureC:02}°C";
          format-icons = ["󱃃" "󰔏" "󱃂"];
          interval = 1;
        };
        "memory" = {
          interval = 1;
          format = "{used:0.1f}G/{total:0.1f}G ";
        };
        "clock" = {
          interval = 60;
          format-alt = "{:%A, %B %d, %Y - %R}";
        };
        "disk#root" = {
          interval = 30;
          format = "{path} {percentage_used}%";
          path = "/";
        };
        "disk#home" = {
          interval = 30;
          format = "{path} {percentage_used}%";
          path = "/home";
        };
        "pulseaudio" = {
          "format" = "{volume}% {icon}";
          "format-bluetooth" = "{volume}% {icon}";
          "format-muted" = "";
          "format-icons" = {
            "headphone" = "";
            "default" = ["" ""];
          };
          "scroll-step" = 1;
          "on-click" = "hyprctl dispatch exec '${createToggleApp "pavucontrol"}'";
          "ignored-sinks" = ["Easy Effects Sink"];
        };
        "network" = {
          "interval" = 1;
          "format" = "{ifname}";
          "format-wifi" = "{essid} ({signalStrength}%) ";
          "format-ethernet" = "{ipaddr} 󰈁";
          "format-disconnected" = "󰈂";
        };
        "tray" = {
          spacing = 10;
        };
      };
    };
    style = ''
      * {
          background: transparent;
          border: none;
          border-radius: 10px;
          font-family: ${settings.font};
          font-size: 13px;
          min-height: 0;
      }
      #workspaces button {
          background: #${config.colorScheme.palette.base02};
          color: #${config.colorScheme.palette.base05};
          padding-left: 10px;
          padding-right: 10px;
          margin-left: 1px;
          margin-right: 1px;
      }
      #workspaces button.active  {
          background-color: #${config.colorScheme.palette.base03};
          background: #${config.colorScheme.palette.base03};
          color: #${config.colorScheme.palette.base05};
      }
      #submap {
          background-color: #${config.colorScheme.palette.base03};
          background: #${config.colorScheme.palette.base03};
          color: #${config.colorScheme.palette.base05};
          padding-left: 10px;
          padding-right: 10px;
      }
      #submap.resize  {
          background-color: #${config.colorScheme.palette.base0B};
          background: #${config.colorScheme.palette.base0B};
          color: #${config.colorScheme.palette.base05};
      }
      #submap.move  {
          background-color: #${config.colorScheme.palette.base0D};
          background: #${config.colorScheme.palette.base0C};
          color: #${config.colorScheme.palette.base05};
      }
      #battery,
      #cpu,
      #memory,
      #disk,
      #temperature,
      #network,
      #pulseaudio,
      #tray,
      #clock {
        background-color:  #${config.colorScheme.palette.base02};
        color: #${config.colorScheme.palette.base05};
        padding-left: 10px;
        padding-right: 10px;
        margin-left: 1px;
        margin-right: 1pX;
      }
      #temperature.critical {
        background-color:  #${config.colorScheme.palette.base08};
        color: #${config.colorScheme.palette.base05};
      }

    '';
  };
  wayland.windowManager.hyprland = {
    enable = isLinux;
    extraConfig = ''
      # Required for mouse to render
      env = WLR_NO_HARDWARE_CURSORS,1

      env = HYPRCURSOR_THEME,macOS-BigSur-White
      env = HYPRCURSOR_SIZE,24
      env = XCURSOR_THEME,macOS-BigSur-White
      env = XCURSOR_SIZE,24
      # Startup applications
      exec-once = waybar
      exec-once = blueman-applet

      exec-once = wl-paste --type text --watch cliphist store #Stores only text data

      exec-once = wl-paste --type image --watch cliphist store #Stores only image data

      ${createBarWindowRule "pavucontrol" 50 700}
      ${createBarWindowRule ".blueman-manager-wrapped" 50 700}
      ${createBarWindowRule "1Password" 50 700}

      windowrule=workspace 2,^(Mullvad.*)$
      windowrule=move 100%-350 50,^(Mullvad.*)$
      windowrule=float,^(Mullvad.*)$
      windowrule=animation slide,^(Mullvad.*)$

      windowrulev2 = stayfocused,class:(Rofi)
      windowrulev2 = forceinput,class:(Rofi)

      # Monitor left
      monitor=${monitorLeft.screen},${monitorLeft.res}@${monitorLeft.hertz},${monitorLeft.pos},${monitorLeft.scale},transform,${monitorLeft.transform}

      # Monitor centre
      monitor=${monitorCentre.screen},${monitorCentre.res}@${monitorCentre.hertz},${monitorCentre.pos},${monitorCentre.scale}

      # Monitor right
      monitor=${monitorRight.screen},${monitorRight.res}@${monitorRight.hertz},${monitorRight.pos},${monitorRight.scale}
      monitor=,preferred,auto,1

      workspace=1,monitor:DP-2,default:true
      workspace=2,monitor:HDMI-A-1,defualt:true
      workspace=3,monitor:DP-1,default:true

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

      bind = $mainMod, SPACE, exec, rofi -show drun -log -config "${settings.homeDir}/.config/rofi/config.rasi"
      bind = $mainMod, TAB, exec, rofi -show window -config "${settings.homeDir}/.config/rofi/config.rasi"
      bind = $mainMod, grave, exec, rofi -show run  -config "${settings.homeDir}/.config/rofi/config.rasi"
      bind = $mainMod, C, exec, cliphist list | rofi -dmenu | cliphist decode | wl-copy
      bind = , print, exec, grim -g "$(slurp)" $HOME/Pictures/Screenshots/$(date +'%s_grim.png')


      # Doesn't work as intended, possibly wayland issues
      # bind = $mainMod, p, exec, rofi-capture

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

      bind = $shiftMod, S, movetoworkspace, special
      bind = $mainMod, S, togglespecialworkspace, special

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
            font_family = "${settings.font}"
            font_size = 10
            height = 16
            col.active = 0x${config.colorScheme.palette.base04}ff
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
