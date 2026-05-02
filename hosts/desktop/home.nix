{inputs, ...}: {
  imports = [
    ../../home
    ../../home/ui
    inputs.noctalia.homeModules.default
  ];

  my.features = {
    dropbox.enable = true;
    desktop = {
      enable = true;
      hyprland.enable = true;
      noctalia.enable = true;
      notifications.enable = true;
      rofi.enable = true;
    };
  };
}
