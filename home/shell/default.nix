{
  settings,
  pkgs,
  ...
}: let
  isDarwin = pkgs.stdenv.isDarwin;
  isLinux = pkgs.stdenv.isLinux;
  userName = settings.userName;
  homeDir = settings.homeDir;
  dotFiles = "${homeDir}/.dotfiles";
  flake-cmds = import ./scripts/flake-init.nix;

  capture-cmds =
    if isLinux
    then
      (import ./scripts/screen-capture.nix {
        inherit pkgs;
        inherit settings;
      })
      .cmds
    else [];

  # Very simple rust project for piping into nvim and saving into random scratch dir or named file.
  # Defined here because zsh_funcs  has a dependency on it.
  # TODO: not much logic involved so should probably be a bash script instead - although good simple example of the
  # power of nix. This should now be reproducible.
  vdoc = pkgs.rustPlatform.buildRustPackage {
    pname = "vdoc";
    version = "0.1.0";
    src = pkgs.fetchFromGitHub {
      owner = "HPRIOR";
      repo = "vdoc";
      rev = "master";
      sha256 = "f//x7jizvnh5f0OdTF1vvX97FaO6Y73zQgXGbQr7ltw=";
    };
    cargoSha256 = "+5bF0/c4yoKAFWRE+/CSYpmD2IMGTuuHsb5nMKgS6SA=";
  };

  aliases_linux = {
    buildwork = "sudo nixos-rebuild switch --flake ${dotFiles}#work";

    cap = "grim -g \"$(slurp)\" $HOME/Pictures/Screenshots/$(date +'%s_grim.png')";
    scap = "grim -g \"$(slurp -o)\" $HOME/Pictures/Screenshots/$(date +'%s_grim.png')";
  };

  aliases_all = rec {
    v = "nvim";

    ai = "aichat --model openai:gpt-4o";

    buildnix = let
      buildcmd =
        if isDarwin
        then "darwin-rebuild switch --flake ${dotFiles}"
        else "sudo nixos-rebuild switch --flake ${dotFiles}";
    in "echo 'Building nix config' && ${buildcmd} && echo 'Cleaning old generations' && sudo nix-env --delete-generations +20 --profile /nix/var/nix/profiles/system";

    buildnix-dev = let
      buildcmd =
        if isDarwin
        then "darwin-rebuild switch --flake ${dotFiles}"
        else "sudo nixos-rebuild switch --flake ${dotFiles}";
    in "echo 'Building nix config' && ${buildcmd}";

    updatenix = "nix flake update ${dotFiles} && ${buildnix}";

    editnix = "cd ${dotFiles} && nvim && cd -";

    editdocs = "cd ${homeDir}/Documents/vdoc && nvim && cd -";

    editnotes = "cd ${homeDir}/Documents/Notes && nvim && cd -";



    nixdev = "nix develop -c zsh";

    nix-clean-generations = "sudo nix-env --delete-generations +20 --profile /nix/var/nix/profiles/system";

    cdstore = ''cd "/nix/store/$(ls -D /nix/store | fzf)"'';

    ncg = "nix-collect-garbage -d";
    # lazy
    lzg = "lazygit";
    lzd = "lazydocker";

    # zsh
    sourcezsh = "source ${homeDir}/.zshrc";

    # modern replacements
    diff = "difft";
    cat = "bat";
    ls = "exa";
    ll = "exa -l --git";
    lla = "exa -la --git";
    la = "exa -a --git";
    changes = "git diff */**";

    copy =
      if isDarwin
      then "pbcopy"
      else "wl-copy";

    paste =
      if isDarwin
      then "pbpaste"
      else "wl-paste";
  };
  aliases =
    if isLinux
    then aliases_linux // aliases_all // flake-cmds
    else aliases_all // flake-cmds;
in {
  imports = [];

  home.packages = with pkgs;
    [
      vdoc
    ]
    ++ capture-cmds;

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
      plugins = ["git" "sudo" "copypath" "copyfile" "history" "direnv" "copybuffer"];
      theme = "robbyrussell";
    };
    shellAliases = aliases;
    initExtra = let
      linuxFuncs =
        if isLinux
        then builtins.readFile ./zsh_funcs_linux
        else "";

      control-x-binds =
        if isLinux
        then ''
          bindkey "^H" backward-delete-word
          bindkey '^[^H' backward-kill-line
          bindkey '^[[3;5~' kill-word
          bindkey '^[[3;7~' kill-line
        ''
        else "";
    in ''
      eval "$(zoxide init zsh)"
      eval $(thefuck --alias)
      source ${pkgs.zsh-fzf-tab}/share/fzf-tab/fzf-tab.plugin.zsh
      ${builtins.readFile ./zsh_funcs}
      ${linuxFuncs}
      ${control-x-binds}
      ## not working correctly with direnv, because no change in shell occurs, so no refresh
      ## set_nix_shell_prompt() {
      ##   if [[ -n "$IN_NIX_SHELL" || -n "$DIRENV_FILE" ]]; then
      ##       echo "%F{cyan}%F{cyan} "
      ##   fi
      ##  }
      ## PROMPT="$PROMPT$(set_nix_shell_prompt)"
    '';
  };

  programs.zoxide = {
    enable = true;
    options = [];
  };

  programs.direnv = {
    enable = true;
    enableZshIntegration = true; # see note on other shells below
    nix-direnv.enable = true;
  };
}
