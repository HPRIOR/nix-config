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
    image_name=$(aichat --no-highlight --no-stream -f "$image_path" "Return a suitable filename for the attached picture assuming its a screenshot. Only return the filename, and be descriptive enough to differentiate between similar screenshots. Appoend the date: $(date +'%H-%M-%S_%d-%m-%Y')" )
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

  # todo was this nor working?
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
in {
  cmds = [
    capture-selection
    capture-screen
    clip-selection
    clip-screen
    smart-selection
    smart-screen
  ];

}
