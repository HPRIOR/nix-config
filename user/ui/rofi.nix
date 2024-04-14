{
  userSettings,
  config,
  ...
}: {
  home.file.".config/rofi/config.rasi".text = ''
    configuration {
        	font: "${userSettings.font}";
            show-icons: true;
            terminal: "kitty";
            run-command: "{cmd}";
            run-shell-command: "{terminal} -e {cmd}";
    }

    @theme "/dev/null"


    * {
        bg: #${config.colorScheme.palette.base00};
        bg-alt: #${config.colorScheme.palette.base02};

        fg: #${config.colorScheme.palette.base06};
        fg-alt: #${config.colorScheme.palette.base07};

        background-color: @bg;
        color: @fg;

    }

    window {
        width: 40%;
    }

    inputbar,
    listview,
    mod-switcher
    message,
    textbox,
    mainbox {
        padding: 10px;
        margin: 10px;
    }

  '';
}
