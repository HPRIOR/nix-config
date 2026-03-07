self: super: {
  ron-lsp = super.rustPlatform.buildRustPackage {
    pname = "ron-lsp";
    version = "unstable-2026-03-07";

    src = super.fetchFromGitHub {
      owner = "jasonjmcghee";
      repo = "ron-lsp";
      rev = "v0.1.3";
      hash = "sha256-+fMV2J6S6+vRmdSsS6TtrCGxxOw+dgL4dEJWsJpB5bY=";
    };

    cargoHash = "sha256-vJ0+M0Mg2ONfGcKqGs2hffMAdcgawra1cHWPeaqpo1w=";

    meta = {
      description = "Language server for RON files.";
      homepage = "https://github.com/jasonjmcghee/ron-lsp";
      mainProgram = "ron-lsp";
    };
  };
}
