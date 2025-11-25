{
  pkgs,
  settings,
}: let
  captureSelectionCmd = "capture-selection";
  captureScreenCmd = "capture-screen";
  clipScreenCmd = "clip-screen";
  clipSelectionCmd = "clip-selection";
  smartCaptureSelectionCmd = "smart-capture-selection";
  smartCaptureScreenCmd = "smart-capture-screen";
  rofi-capture-cmd = "rofi-capture";
  moveWindowNextWorkspaceCmd = "move-window-next-workspace";
  screenshot-path = "\"$HOME\"/Pictures/Screenshots";

  capture = slurpCmd: ''
    #!/bin/zsh
    mkdir -p ${screenshot-path}
    image_path=${screenshot-path}/"$(date +'%H-%M-%S_%d-%m-%Y_screenshot.png')"
    grim -g "$(${slurpCmd})" "$image_path"
    notyclick=$(dunstify -I "$image_path" "Screenshot captured" "Click to copy to clipboard" -A "copy,copyCmd")
    case $notyclick in
      copy)
          wl-copy < "$image_path" && dunstify "Screenshot copied to clipboard!" "$image_path"
          ;;
      2)
          exit 0
          ;;
      esac
  '';

  smartCapture = slurpCmd: ''
    #!/bin/zsh
    mkdir -p ${screenshot-path}
    image_path=${screenshot-path}/"$(date +'%H-%M-%S_%d-%m-%Y_screenshot.png')"
    grim -g "$(${slurpCmd})" "$image_path"
    image_name=$(aichat  --no-stream -f "$image_path" "Return a suitable filename for the attached picture assuming its a screenshot. Only return the filename, and be descriptive enough to differentiate between similar screenshots. Appoend the date: $(date +'%H-%M-%S_%d-%m-%Y')" )
    new_image_path=${screenshot-path}/"$image_name"
    mv "$image_path" "$new_image_path"
  '';

  clip = slurpCmd: ''
    #!/bin/zsh
    mkdir -p ${screenshot-path}
    image_path=${screenshot-path}/"$(date +'%H-%M-%S_%d-%m-%Y_screenshot.png')"
    grim -g "$(${slurpCmd})" "$image_path"
    notyclick=$(dunstify -I "$image_path" "Screenshot saved to clipboard" "Click to save" -A "save,saveCmd")
    wl-copy < "$image_path" && dunstify "Screenshot copied to clipboard!" "$image_path"
    case $notyclick in
      save)
          exit 0
          ;;
      2)
          rm "$image_path"
          ;;
    esac
  '';

  capture-selection = pkgs.writeShellApplication {
    name = captureSelectionCmd;

    runtimeInputs = with pkgs; [slurp grim zsh wl-clipboard dunst];

    text = capture "slurp";
  };

  capture-screen = pkgs.writeShellApplication {
    name = captureScreenCmd;

    runtimeInputs = with pkgs; [slurp grim zsh];

    text = capture "slurp -o";
  };

  clip-selection = pkgs.writeShellApplication {
    name = clipSelectionCmd;

    runtimeInputs = with pkgs; [slurp grim zsh wl-clipboard dunst];

    text = clip "slurp";
  };

  clip-screen = pkgs.writeShellApplication {
    name = clipScreenCmd;

    runtimeInputs = with pkgs; [slurp grim zsh wl-clipboard dunst];

    text = clip "slurp -o";
  };

  smart-selection = pkgs.writeShellApplication {
    name = smartCaptureSelectionCmd;

    runtimeInputs = with pkgs; [slurp grim zsh wl-clipboard dunst];

    text = smartCapture "slurp";
  };

  smart-screen = pkgs.writeShellApplication {
    name = smartCaptureScreenCmd;

    runtimeInputs = with pkgs; [slurp grim zsh wl-clipboard dunst];

    text = smartCapture "slurp -o";
  };

  # todo was this not working?
  _ = pkgs.writeShellApplication {
    name = rofi-capture-cmd;

    runtimeInputs = with pkgs; [rofi grim zsh slurp];

    text = ''
      #!/bin/bash

      # Options
      options="selection\nscreen"

      # Rofi command
      chosen=$(echo -e "$options" | rofi -dmenu -p "Screen capture:"  -config "${settings.homeDir}/.config/rofi/config.rasi")

      case $chosen in
          selection)
              ${captureSelectionCmd}
              ;;
          screen)
              ${captureScreenCmd}
              ;;
      esac

    '';
  };

  focus_window = pkgs.writeShellApplication {
    name = "focus_window";

    runtimeInputs = with pkgs; [jq];

    text = ''
      #!/bin/sh
      address="$1"

      button="$2"

      if [ "$button" -eq 1 ]; then
          # Left click: focus window
          hyprctl keyword cursor:no_warps true
          hyprctl dispatch focuswindow address:"$address"
          hyprctl keyword cursor:no_warps false
      elif [ "$button" -eq 2 ]; then
          # Middle click: close window
          hyprctl dispatch closewindow address:"$address"
      fi
    '';
  };
  move_window_next_workspace = pkgs.writeShellApplication {
    name = moveWindowNextWorkspaceCmd;

    runtimeInputs = with pkgs; [hyprland jq];

    text = ''
      #!/bin/sh
      set -euo pipefail

      active_window=$(hyprctl -j activewindow)
      if [ "$active_window" = "null" ] || [ -z "$active_window" ]; then
          exit 0
      fi

      next_workspace=$(
        hyprctl -j workspaces \
        | jq '
            [.[].id]
            | map(select(. > 0))
            | sort
            | reduce .[] as $id (1; if $id == . then . + 1 else . end)
          '
      )

      hyprctl dispatch movetoworkspace "$next_workspace"
    '';
  };
in {
  cmds = [
    capture-selection
    capture-screen
    clip-selection
    clip-screen
    smart-selection
    smart-screen
    focus_window
    move_window_next_workspace
  ];
}
