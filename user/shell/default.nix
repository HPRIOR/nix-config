{
  userSettings,
  pkgs,
  ...
}: let
  userName = userSettings.userName;
  homeDir = "/home/${userName}";
  dotFiles = "${homeDir}/.dotfiles";

  # Very simple rust project for piping into nvim and saving into random scratch dir or named file.
  # Defined here because zsh_funcs  has a dependency on it.
  # TODO: not much logic involved so should probably be a bash script instead - although good simple example of the
  # power of nix. This should now be reproducible.
  vdoc = pkgs.rustPlatform.buildRustPackage rec {
    pname = "vdoc";
    version = "0.1.0";
    src = pkgs.fetchFromGitHub {
      owner = "HPRIOR";
      repo = "vdoc";
      rev = "master";
      sha256 = "f//x7jizvnh5f0OdTF1vvX97FaO6Y73zQgXGbQr7ltw="; # Update this with the correct hash
    };
    cargoSha256 = "+5bF0/c4yoKAFWRE+/CSYpmD2IMGTuuHsb5nMKgS6SA="; # Update this as well
  };

  aliases = rec {
    # nix editing
    editconfig = "cd ${dotFiles}/system && nvim configuration.nix && cd -";
    buildconfig = "sudo nixos-rebuild switch --flake ${dotFiles}";
    edithome = "cd ${dotFiles}/user && nvim home.nix && cd -";
    buildhome = "home-manager switch --flake ${dotFiles}";
    editnix = "cd ${dotFiles} && nvim && cd -";
    buildnix = "${buildconfig} && ${buildhome}";

    # lazy
    lzg = "lazygit";
    lzd = "lazydocker";

    # zsh
    sourcezsh = "source ${homeDir}/.zshrc";

    # modern replacements
    diff = "difft";
    cat = "bat";
    ls = "exa";
    ll = "exa -l";
    lla = "exa -la";
    la = "exa -a";
    changes = "git diff */**";
    copy = "wl-copy";
    paste = "wl-paste";
  };
in {
  imports = [];

  home.packages = with pkgs; [
    vdoc
  ];

  programs.bash = {
    enable = false;
    shellAliases = aliases;
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    oh-my-zsh = {
      enable = true;
      plugins = ["git" "sudo" "copypath" "copyfile" "history"];
      theme = "robbyrussell";
    };
    shellAliases = aliases;
    initExtra = ''
      eval "$(zoxide init zsh)"
      source ${pkgs.zsh-fzf-tab}/share/fzf-tab/fzf-tab.plugin.zsh
      ${builtins.readFile ./zsh_funcs}

    '';
  };

  programs.zoxide = {
    enable = true;
    options = [];
  };
}
