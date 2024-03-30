{ pkgs }:

pkgs.writeShellApplication {
    name = "build-nix";

    runtimeInputs = [];

    text = ''
        echo "hello world"
    '';
} 

