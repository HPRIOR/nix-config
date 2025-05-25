{
  settings,
  pkgs,
  ...
}: let
  isLinux = pkgs.stdenv.isLinux;

  capture-cmds =
    if isLinux
    then
      (import ./scripts/screen-capture.nix {
        inherit pkgs;
        inherit settings;
      })
      .cmds
    else [];

  vdoc = pkgs.rustPlatform.buildRustPackage {
    pname = "vdoc";
    version = "0.1.0";
    src = pkgs.fetchFromGitHub {
      owner = "HPRIOR";
      repo = "vdoc";
      rev = "master";
      sha256 = "f//x7jizvnh5f0OdTF1vvX97FaO6Y73zQgXGbQr7ltw=";
    };
    cargoHash = "sha256-97BdwCbSKYz7wdEQslHwoDyGK4GSbmJlSt8oK7XenlM=";
  };

  mkAlias = (import ./alias.nix) {
    pkgs = pkgs;
    settings = settings;
  };
  alias_shared = mkAlias.shared;
  alias_combined = mkAlias.shared // mkAlias.linux;

  aliases =
    if isLinux
    then alias_combined
    else alias_shared;
in {
  imports = [];

  home.packages = [vdoc] ++ capture-cmds;

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
      plugins = ["git" "sudo" "copypath" "copyfile" "history" "direnv" "copybuffer" "colored-man-pages"];
      theme = "robbyrussell";
    };
    shellAliases = aliases;
    initContent = let
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
      eval "$(atuin init zsh --disable-up-arrow --disable-ctrl-r)"
      eval "$(zoxide init zsh)"
      eval $(thefuck --alias)
      source ${pkgs.zsh-fzf-tab}/share/fzf-tab/fzf-tab.plugin.zsh
      ${builtins.readFile ./zsh_funcs}
      ${linuxFuncs}
      ${control-x-binds}

      RPROMPT='%{$fg[yellow]%}[%D{%Y-%m-%d %H:%M:%S}]%{$reset_color%}'
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
