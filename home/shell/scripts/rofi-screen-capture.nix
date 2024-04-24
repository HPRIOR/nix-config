{
  pkgs,
  settings,
}: let
  capture-selection-cmd = "capture-selection";
  capture-screen-cmd = "capture-screen";
  rofi-capture-cmd = "rofi-capture";
  screenshot-path = "\"$HOME\"/Pictures/Screenshots";

  capture-selection = pkgs.writeShellApplication {
    name = capture-selection-cmd;

    runtimeInputs = with pkgs; [slurp grim zsh];

    text = ''
      #!/bin/zsh
      mkdir -p ${screenshot-path}
      grim -g "$(slurp)" ${screenshot-path}/"$(date +'%s_screenshot.png')"
    '';
  };

  capture-screen = pkgs.writeShellApplication {
    name = capture-screen-cmd;

    runtimeInputs = with pkgs; [slurp grim zsh];

    text = ''
      #!/bin/zsh
      mkdir -p ${screenshot-path}
      grim -g "$(slurp -o)" ${screenshot-path}/"$(date +'%s_screenshot.png')"
    '';
  };

  rofi-capture = pkgs.writeShellApplication {
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
              ${capture-selection-cmd}
              ;;
          screen)
              ${capture-screen-cmd}
              ;;
      esac

    '';
  };
in {
  cmds = [capture-selection capture-screen rofi-capture];
}
