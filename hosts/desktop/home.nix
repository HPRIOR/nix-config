{
  inputs,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ../../home
    inputs.noctalia.homeModules.default
  ];

  home.packages = [
    pkgs.litra-autotoggle
  ];

  systemd.user.services.litra-autotoggle = {
    Unit = {
      Description = "Logitech Litra auto-toggle based on webcam activity";
      Documentation = "https://github.com/timrogers/litra-autotoggle";
    };

    Service = {
      ExecStart = lib.getExe pkgs.litra-autotoggle;
      Restart = "on-failure";
      RestartSec = 5;
    };

    Install.WantedBy = ["default.target"];
  };
}
