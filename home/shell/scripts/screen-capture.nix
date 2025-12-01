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
  deleteWorkspaceCmd = "delete-current-workspace";
  focusHistoryDaemonCmd = "focus-history-daemon";
  focusHistoryNextCmd = "focus-history-next";
  focusHistoryPrevCmd = "focus-history-prev";
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
  focus_history_daemon = pkgs.writeShellApplication {
    name = focusHistoryDaemonCmd;

    runtimeInputs = with pkgs; [hyprland jq socat coreutils bash];

    text = ''
      #!/usr/bin/env bash
      set -euo pipefail

      socket="/tmp/hypr/''${HYPRLAND_INSTANCE_SIGNATURE:-default}/.socket2.sock"
      history_file="''${XDG_RUNTIME_DIR:-/tmp}/hypr-focus-history-''${HYPRLAND_INSTANCE_SIGNATURE:-default}"
      mkdir -p "$(dirname "$history_file")"
      : > "$history_file"

      add_to_history() {
        addr="$1"
        [ -z "$addr" ] && return
        tmp=$(mktemp)
        {
          printf '%s\n' "$addr"
          cat "$history_file"
        } | awk '!seen[$0]++' > "$tmp"
        mv "$tmp" "$history_file"
      }

      remove_from_history() {
        addr="$1"
        [ -z "$addr" ] && return
        tmp=$(mktemp)
        awk -v drop="$addr" '$0 != drop {print}' "$history_file" > "$tmp"
        mv "$tmp" "$history_file"
      }

      init_active=$(hyprctl -j activewindow | jq -r '.address // empty')
      [ -n "$init_active" ] && add_to_history "$init_active"

      # exit early if we cannot read socket
      [ -S "$socket" ] || exit 0

      socat - UNIX-CONNECT:"$socket" | while IFS= read -r line; do
        event=''${line%%>>*}
        payload=''${line#*>>}
        addr=''${payload%%,*}

        case "$event" in
          activewindow|activewindowv2)
            add_to_history "$addr"
            ;;
          closewindow)
            remove_from_history "$addr"
            ;;
          *)
            ;;
        esac
      done
    '';
  };

  focus_history_cycle = direction: pkgs.writeShellApplication {
    name =
      if direction == "next"
      then focusHistoryNextCmd
      else focusHistoryPrevCmd;

    runtimeInputs = with pkgs; [hyprland jq coreutils bash];

    text = ''
      #!/usr/bin/env bash
      set -euo pipefail

      history_file="''${XDG_RUNTIME_DIR:-/tmp}/hypr-focus-history-''${HYPRLAND_INSTANCE_SIGNATURE:-default}"
      state_file="''${history_file}.state"

      [ -f "$history_file" ] || exit 0

      mapfile -t history < "$history_file"
      len=''${#history[@]}
      if [ "$len" -eq 0 ]; then
        exit 0
      fi

      active=$(hyprctl -j activewindow | jq -r '.address // empty')

      anchor=""
      offset=0
      last_target=""
      if [ -f "$state_file" ]; then
        # shellcheck source=/dev/null
        . "$state_file"
      fi

      if [ "$active" != "$last_target" ]; then
        anchor="$active"
        offset=0
      fi

      if [ "$len" -le 1 ]; then
        exit 0
      fi

      direction_flag="${direction}"
      if [ "$direction_flag" = "next" ]; then
        offset=$(( (offset + 1) % len ))
      else
        offset=$(( (offset - 1 + len) % len ))
      fi

      target=''${history[$offset]}
      if [ -z "$target" ]; then
        exit 0
      fi

      hyprctl dispatch focuswindow address:"$target"

      cat > "$state_file" <<EOF
anchor="$anchor"
offset=$offset
last_target="$target"
EOF
    '';
  };

  focus_history_next = focus_history_cycle "next";
  focus_history_prev = focus_history_cycle "prev";
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
    delete_current_workspace
    focus_history_daemon
    focus_history_next
    focus_history_prev
  ];
}
