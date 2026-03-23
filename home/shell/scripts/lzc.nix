{
  pkgs,
}: let
  lzc = pkgs.writeShellApplication {
    name = "lzc";

    runtimeInputs = with pkgs; [git python3];

    text = ''
      exec python3 ${./lzc.py} "$@"
    '';
  };
in {
  cmds = [lzc];
}
