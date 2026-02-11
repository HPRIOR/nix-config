{
  pkgs,
  config,
  lib,
  inputs,
  settings,
  ...
}: let
  isLinux = pkgs.stdenv.isLinux;
  createBarWindowRule = app: verticalSizePercent: horizontalSize: ''
    windowrule=workspace 2,class:${app}
    windowrule=size ${toString horizontalSize} ${toString verticalSizePercent}%,class:${app}
    windowrule=move 100%-${toString (horizontalSize + 30)} 50,class:${app}
    windowrule=float,class:${app}
    windowrule=animation slide,class:${app}
  '';

  # Todo create a function that will generate the position of each screan automatically
  monitorLeft = {
    desc = "LG Electronics LG ULTRAFINE 201NTHM23033";
    screen = "DP-3";
    res = "3840x2160";
    hertz = "59.997002";
    pos = "-1440x-400";
    scale = "1.5";
    transform = "1";
  };
  monitorCentre = {
    desc = "Samsung Electric Company S34J55x H4LNB01202";
    screen = "HDMI-A-1";
    res = "3440x1440";
    hertz = "74.983002";
    pos = "0x0";
    scale = "1";
    transform = throw "No transform set for monitor centre";
  };
  monitorRight = {
    desc = "LG Electronics LG SDQHD 307NTDVEQ250";
    screen = "DP-2";
    res = "2560x2880";
    hertz = "59.966999";
    pos = "3440x0";
    scale = "1.5";
    transform = throw "No transform set for monitor centre";
  };
in {
  imports = [
    ./rofi.nix
    ./notifications.nix
  ];

  programs =
    if isLinux
    then {
      noctalia-shell = lib.mkIf isLinux {
        enable = isLinux;
        package = inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default;
        systemd.enable = true;

        settings = {
          general = {
            scaleRatio = 1;
            radiusRatio = 1;
            gapsIn = 4;
            gapsOut = 6;
            activeScreenBorder = false;
            screenCorners = false;
          };

          bar = {
            position = "top";
            density = "compact";
            showCapsule = false;
            backgroundOpacity = 0.95;
            widgets = {
              left = [
                {id = "Launcher";}
                {
                  id = "Workspace";
                  labelMode = "icon";
                  showIndicator = true;
                  activeIndicatorHeight = 4;
                  showScreenName = true;
                  workspacesToShow = 10;
                }
                {id = "ActiveWindow";}
              ];
              center = [];
              right = [
                {id = "SystemMonitor";}
                {id = "Volume";}
                {id = "Network";}
                {id = "Bluetooth";}
                {id = "Tray";}
                {
                  id = "Clock";
                  formatHorizontal = "dd MMM - HH:mm";
                  useMonospacedFont = true;
                }
                {id = "ControlCenter";}
              ];
            };
          };

          appLauncher = {
            enableClipboardHistory = true;
            enableConsole = true;
            enableWindowsSearch = true;
          };

          location = {
            name = "London";
          };

          ui = {
            fontDefault = settings.font;
          };

          wallpaper = {
            enabled = false;
          };
        };
      };

      colors = {
        mPrimary = "#${config.colorScheme.palette.base0D}";
        mSecondary = "#${config.colorScheme.palette.base0B}";
        mTertiary = "#${config.colorScheme.palette.base0E}";
        mSurface = "#${config.colorScheme.palette.base00}";
        mSurfaceVariant = "#${config.colorScheme.palette.base01}";
        mOnSurface = "#${config.colorScheme.palette.base05}";
        mOnSurfaceVariant = "#${config.colorScheme.palette.base04}";
        mOnPrimary = "#${config.colorScheme.palette.base00}";
        mOnSecondary = "#${config.colorScheme.palette.base00}";
        mOnTertiary = "#${config.colorScheme.palette.base00}";
        mError = "#${config.colorScheme.palette.base08}";
        mOnError = "#${config.colorScheme.palette.base00}";
        mOutline = "#${config.colorScheme.palette.base03}";
        mShadow = "#${config.colorScheme.palette.base00}";
        mHover = "#${config.colorScheme.palette.base02}";
        mOnHover = "#${config.colorScheme.palette.base05}";
      };
    }
    else {};

  home.file.".cache/noctalia/wallpapers.json" = lib.mkIf isLinux {
    text = builtins.toJSON {
      defaultWallpaper = "";
      wallpapers = {};
    };
  };
  wayland.windowManager.hyprland = {
    enable = isLinux;
    extraConfig = ''
      # Required for mouse to render
      env = LIBVA_DRIVER_NAME,nvidia
      env = __GLX_VENDOR_LIBRARY_NAME,nvidia
      env = HYPRCURSOR_THEME,rose-pine-hyprcursor
      env = HYPRCURSOR_SIZE,24
      env = XCURSOR_THEME,BreezeX-RosePine-Linux
      env = XCURSOR_SIZE,24
      env = XDG_SESSION_TYPE,wayland
      env = GBM_BACKEND,nvidia-drm

      cursor {
          no_hardware_cursors = true
      }


      # Startup applications
      exec-once = blueman-applet

      exec-once = wl-paste --type text --watch cliphist store #Stores only text data
      exec-once = wl-paste --type image --watch cliphist store #Stores only image data

      exec-once = ~/Scripts/hyprhist daemon focus

      ${createBarWindowRule "pavucontrol" 50 700}
      ${createBarWindowRule ".blueman-manager-wrapped" 50 700}
      ${createBarWindowRule "1Password" 50 700}

      windowrule=workspace 2,class:^(Mullvad.*)$
      windowrule=move 100%-350 50,class:^(Mullvad.*)$
      windowrule=float,class:^(Mullvad.*)$
      windowrule=animation slide,class:^(Mullvad.*)$

      # windowrulev2 = stayfocused,class:(Rofi)
      # windowrulev2 = forceinput,class:(Rofi)

      # Monitor left
      monitor=desc:${monitorLeft.desc},${monitorLeft.res}@${monitorLeft.hertz},${monitorLeft.pos},${monitorLeft.scale},transform,${monitorLeft.transform}

      # Monitor centre
      monitor=desc:${monitorCentre.desc},${monitorCentre.res}@${monitorCentre.hertz},${monitorCentre.pos},${monitorCentre.scale}

      # Monitor right
      # monitor=desc:${monitorRight.desc},${monitorRight.res}@${monitorRight.hertz},${monitorRight.pos},${monitorRight.scale}

      monitor=,preferred,auto,1

      monitor=Unknown-1,disable

      workspace=1,monitor:desc:${monitorLeft.desc},default:true,persistent:true
      workspace=2,monitor:desc:${monitorCentre.desc},default:true,persistent:true
      workspace=3,monitor:desc:${monitorRight.desc},default:true,persistent:true

      # Key bindings
      $mainMod = SUPER
      $shiftMod = SUPERSHIFT
      bind = $mainMod, Return, exec, ghostty
      bind = $shiftMod, Q, killactive

      bind = $mainMod, H, movefocus, l
      bind = $mainMod, J, movefocus, d
      bind = $mainMod, K, movefocus, u
      bind = $mainMod, L, movefocus, r
      bind = $shiftMod, H, movewindoworgroup, l
      bind = $shiftMod, J, movewindoworgroup, d
      bind = $shiftMod, K, movewindoworgroup, u
      bind = $shiftMod, L, movewindoworgroup, r

      bind = $mainMod, SPACE, exec, noctalia-shell ipc call launcher toggle
      bind = $mainMod, TAB, exec, noctalia-shell ipc call launcher windows
      bind = $mainMod, grave, exec, noctalia-shell ipc call launcher command
      bind = $mainMod, V, exec, noctalia-shell ipc call launcher clipboard
      bind = , print, exec, grim -g "$(slurp)" $HOME/Pictures/Screenshots/$(date +'%s_grim.png')


      # Doesn't work as intended, possibly wayland issues
      # bind = $mainMod, p, exec, rofi-capture

      bind = $mainMod, F, fullscreen, 0
      bind = $shiftMod, F, togglefloating,

      # Window management
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

      # open next available workspace on current monitor
      bind = $mainMod, N, workspace, r+1
      # move active window to next available workspace on current monitor
      bind = $shiftMod, N, exec, move-window-next-workspace
      # delete current workspace (or just its windows if persistent/default)
      bind = $shiftMod, X, exec, delete-current-workspace
      # Cycle through workspaces on single monitor
      bind = $mainMod, bracketleft,  workspace, m-1
      bind = $mainMod, bracketright, workspace, m+1
      # Cycle monitors
      bind = $shiftMod, bracketleft, focusmonitor, l
      bind = $shiftMod, bracketright, focusmonitor, r

      # bind = $mainMod, O, focusmonitor, l
      # bind = $mainMod, I, focusmonitor, r

      # Onlye works within workspaces
      bind = $mainMod, I, exec, ~/Scripts/hyprhist focus next
      bind = $mainMod, O, exec, ~/Scripts/hyprhist focus prev

      # Special workspace
      bind = $shiftMod, S, movetoworkspacesilent, special
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
          repeat_delay = 300
          repeat_rate = 50
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
          inactive_opacity = 1.0
      }

      layerrule = blur, namespace:noctalia-background-.*
      layerrule = ignorealpha 0.5, namespace:noctalia-background-.*
      layerrule = blurpopups, namespace:noctalia-background-.*
    '';
  };
}
