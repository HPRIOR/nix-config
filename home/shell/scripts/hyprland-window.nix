{
  pkgs,
}: let
  moveWindowWorkspaceCmd = "move-window-workspace";

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

  move_window_workspace = pkgs.writeShellApplication {
    name = moveWindowWorkspaceCmd;

    runtimeInputs = with pkgs; [hyprland jq];

    text = ''
      #!/bin/bash
      set -euo pipefail

      direction="''${1:-}"
      case "$direction" in
        next) step=1 ;;
        prev) step=-1 ;;
        *) exit 2 ;;
      esac

      active_window=$(hyprctl -j activewindow)
      if [ "$active_window" = "null" ] || [ -z "$active_window" ]; then
        exit 0
      fi

      current_ws=$(echo "$active_window" | jq -r '.workspace.id')
      case "$current_ws" in
        1|2|3)
          min_ws=1
          max_ws=3
          ;;
        4|5|6)
          min_ws=4
          max_ws=6
          ;;
        7|8|9)
          min_ws=7
          max_ws=9
          ;;
        *) exit 0 ;;
      esac

      target_ws=$((current_ws + step))

      if [ "$target_ws" -lt "$min_ws" ]; then
        target_ws=$max_ws
      elif [ "$target_ws" -gt "$max_ws" ]; then
        target_ws=$min_ws
      fi

      hyprctl dispatch movetoworkspace "$target_ws"
    '';
  };
in {
  cmds = [
    focus_window
    move_window_workspace
  ];
}
