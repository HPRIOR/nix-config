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
    cap = "grim -g \"$(slurp)\" $HOME/Pictures/Screenshots/$(date +'%s_grim.png')";
    scap = "grim -g \"$(slurp -o)\" $HOME/Pictures/Screenshots/$(date +'%s_grim.png')";
  };

  aliases_all = rec {
    v = "nvim";

    buildnix = let
      buildcmd =
        if isDarwin
        then "darwin-rebuild switch --flake ${dotFiles}"
        else "sudo nixos-rebuild switch --flake ${dotFiles}";
    in "echo 'Building nix config' && ${buildcmd} && echo 'Cleaning old generations' && nix-env --delete-generations +20";

    buildnix-dev = let
      buildcmd =
        if isDarwin
        then "darwin-rebuild switch --flake ${dotFiles}"
        else "sudo nixos-rebuild switch --flake ${dotFiles}";
    in "echo 'Building nix config' && ${buildcmd} && echo 'Cleaning old generations'";

    updatenix = "nix flake update ${dotFiles} && ${buildnix}";

    editnix = "cd ${dotFiles} && nvim && cd -";

    editdocs = "cd ${homeDir}/Documents/vdoc && nvim && cd -";

    nixdev = "nix develop -c zsh";

    ncg = "nix-collect-garbage";
    # lazy
    lzg = "lazygit";
    lzd = "lazydocker";

    flake-init = let
      flakeTemplate = ''
        {
          inputs = {
            nixpkgs.url = \"github:NixOS/nixpkgs/nixos-unstable\";
            flake-utils.url = \"github:numtide/flake-utils\";
          };
          outputs = {
            self,
            nixpkgs,
            flake-utils
          }:
            flake-utils.lib.eachDefaultSystem
            (
              system: let
                pkgs = import nixpkgs {
                  inherit system;
                };
              in
                with pkgs; {
                  devShells.default = mkShell {
                    buildInputs = [];
                  };
                }
            );
        }
      '';
    in "echo \"${flakeTemplate}\" > flake.nix";

    direnv-init = let
      dirEnvTemplate = ''
        if ! has nix_direnv_version || ! nix_direnv_version 3.0.4; then
            source_url \"https://raw.githubusercontent.com/nix-community/nix-direnv/3.0.4/direnvrc\" \"sha256-DzlYZ33mWF/Gs8DDeyjr8mnVmQGx7ASYqA5WlxwvBG4=\"
        fi
        use flake'';
    in "echo \"${dirEnvTemplate}\" > .envrc";

    proj-init = "${flake-init} && ${direnv-init} && direnv allow";

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
    then aliases_linux // aliases_all
    else aliases_all;
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
