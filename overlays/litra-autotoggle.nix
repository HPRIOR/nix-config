self: super: {
  litra-autotoggle = super.rustPlatform.buildRustPackage {
    pname = "litra-autotoggle";
    version = "1.4.0";

    src = super.fetchFromGitHub {
      owner = "timrogers";
      repo = "litra-autotoggle";
      rev = "v1.4.0";
      hash = "sha256-fx3j3LIdiSqnsNb66BRzz/q1qlLbPsfrtfKFKesJw0k=";
    };

    cargoHash = "sha256-jCLUdPUGdhFTysKLCqE1JGfUVzzDdvQDFPnelyQcDSY=";

    nativeBuildInputs = [
      super.pkg-config
    ];

    buildInputs = [
      super.systemd
    ];

    postInstall = ''
      install -Dm644 99-litra.rules $out/lib/udev/rules.d/99-litra.rules
    '';

    meta = {
      description = "Automatically toggle Logitech Litra lights based on webcam activity.";
      homepage = "https://github.com/timrogers/litra-autotoggle";
      license = super.lib.licenses.mit;
      mainProgram = "litra-autotoggle";
    };
  };
}
