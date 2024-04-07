{
  userSettings,
  ...
}: let
  userName = userSettings.userName;
  homeDir = "/home/${userName}";
  dotFiles = "${homeDir}/.dotfiles";

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
      ${builtins.readFile ./zsh_funcs}

    '';
  };

  programs.zoxide = {
    enable = true;
    options = [];
  };
}
