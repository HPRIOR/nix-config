{codex-cli-nix, unstable}: self: super: let
  system = super.system or super.stdenv.hostPlatform.system;
in {
  codex = codex-cli-nix.packages.${system}.default;
}
