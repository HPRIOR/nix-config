{
  pkgs,
}: let
  moveWindowNextWorkspaceCmd = "move-window-next-workspace";
  deleteWorkspaceCmd = "delete-current-workspace";

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
      #!/bin/bash
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

  delete_current_workspace = pkgs.writeShellApplication {
    name = deleteWorkspaceCmd;

    runtimeInputs = with pkgs; [hyprland jq coreutils];

    text = ''
      #!/bin/bash
      set -euo pipefail

      current_ws=$(hyprctl -j activeworkspace)
      current_ws_id=$(echo "$current_ws" | jq -r '.id')

      ws_info=$(
        hyprctl -j workspaces \
        | jq --argjson id "$current_ws_id" 'map(select(.id == $id)) | first'
      )

      if [ -z "$ws_info" ] || [ "$ws_info" = "null" ]; then
        exit 0
      fi

      persistent=$(echo "$ws_info" | jq '.persistent // false')
      monitor_name=$(echo "$ws_info" | jq -r '.monitor')

      addresses=$(
        hyprctl -j clients \
        | jq -r --argjson id "$current_ws_id" '.[] | select(.workspace.id == $id) | .address'
      )

      if [ -n "$addresses" ]; then
        echo "$addresses" | while IFS= read -r addr; do
          [ -n "$addr" ] && hyprctl dispatch closewindow address:"$addr"
        done
      fi

      if [ "$persistent" = "true" ]; then
        exit 0
      fi

      target_ws=$(
        hyprctl -j workspaces \
        | jq -r --arg mon "$monitor_name" --argjson cur "$current_ws_id" '
            [ .[] | select(.monitor == $mon and .id != $cur) | .id ] | sort | .[0] // empty
          '
      )

      if [ -z "$target_ws" ]; then
        target_ws=1
      fi

      hyprctl dispatch workspace "$target_ws"
    '';
  };
in {
  cmds = [
    focus_window
    move_window_next_workspace
    delete_current_workspace
  ];
}
