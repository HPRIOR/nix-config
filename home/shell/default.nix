{
  settings,
  pkgs,
  ...
}: let
  isLinux = pkgs.stdenv.isLinux;

  screen-capture-cmds =
    if isLinux
    then
      (import ./scripts/screen-capture.nix {
        inherit pkgs;
        inherit settings;
      })
      .cmds
    else [];

  hyprland-window-cmds =
    if isLinux
    then
      (import ./scripts/hyprland-window.nix {
        inherit pkgs;
      })
      .cmds
    else [];

  diary-cmds = (import ./scripts/diary.nix {
    inherit pkgs;
  }).cmds;
  lzc-cmds = (import ./scripts/lzc.nix {
    inherit pkgs;
  }).cmds;

  linux-cmds = screen-capture-cmds ++ hyprland-window-cmds;

  vdoc = pkgs.rustPlatform.buildRustPackage {
    pname = "vdoc";
    version = "0.1.0";
    src = pkgs.fetchFromGitHub {
      owner = "HPRIOR";
      repo = "vdoc";
      rev = "master";
      sha256 = "sha256-bOHEhp9akx7V//LjGSKOvE8NUN9dnwXEh7i98RHzDKo=";
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

  home.packages = [vdoc] ++ linux-cmds ++ diary-cmds ++ lzc-cmds;

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
      eval "$(pay-respects zsh --alias fuck)"
      source ${pkgs.zsh-fzf-tab}/share/fzf-tab/fzf-tab.plugin.zsh
      ${builtins.readFile ./zsh_funcs}
      ${linuxFuncs}
      ${control-x-binds}
    '';
  };

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
  };
  home.file."${settings.configDir}/starship/starship.toml".text = ''
    [aws]
    symbol = "  "

    [buf]
    symbol = " "

    [bun]
    symbol = " "

    [c]
    symbol = " "

    [cpp]
    symbol = " "

    [cmake]
    symbol = " "

    [conda]
    symbol = " "

    [crystal]
    symbol = " "

    [dart]
    symbol = " "

    [deno]
    symbol = " "

    [directory]
    read_only = " 󰌾"

    [docker_context]
    symbol = " "

    [elixir]
    symbol = " "

    [elm]
    symbol = " "

    [fennel]
    symbol = " "

    [fossil_branch]
    symbol = " "

    [gcloud]
    symbol = "  "

    [git_branch]
    symbol = " "

    [git_commit]
    tag_symbol = '  '

    [golang]
    symbol = " "

    [guix_shell]
    symbol = " "

    [haskell]
    symbol = " "

    [haxe]
    symbol = " "

    [hg_branch]
    symbol = " "

    [hostname]
    ssh_symbol = " "

    [java]
    symbol = " "

    [julia]
    symbol = " "

    [kotlin]
    symbol = " "

    [lua]
    symbol = " "

    [memory_usage]
    symbol = "󰍛 "

    [meson]
    symbol = "󰔷 "

    [nim]
    symbol = "󰆥 "

    [nix_shell]
    symbol = " "

    [nodejs]
    symbol = " "

    [ocaml]
    symbol = " "

    [os.symbols]
    Alpaquita = " "
    Alpine = " "
    AlmaLinux = " "
    Amazon = " "
    Android = " "
    Arch = " "
    Artix = " "
    CachyOS = " "
    CentOS = " "
    Debian = " "
    DragonFly = " "
    Emscripten = " "
    EndeavourOS = " "
    Fedora = " "
    FreeBSD = " "
    Garuda = "󰛓 "
    Gentoo = " "
    HardenedBSD = "󰞌 "
    Illumos = "󰈸 "
    Kali = " "
    Linux = " "
    Mabox = " "
    Macos = " "
    Manjaro = " "
    Mariner = " "
    MidnightBSD = " "
    Mint = " "
    NetBSD = " "
    NixOS = " "
    Nobara = " "
    OpenBSD = "󰈺 "
    openSUSE = " "
    OracleLinux = "󰌷 "
    Pop = " "
    Raspbian = " "
    Redhat = " "
    RedHatEnterprise = " "
    RockyLinux = " "
    Redox = "󰀘 "
    Solus = "󰠳 "
    SUSE = " "
    Ubuntu = " "
    Unknown = " "
    Void = " "
    Windows = "󰍲 "

    [package]
    symbol = "󰏗 "

    [perl]
    symbol = " "

    [php]
    symbol = " "

    [pijul_channel]
    symbol = " "

    [pixi]
    symbol = "󰏗 "

    [python]
    symbol = " "

    [rlang]
    symbol = "󰟔 "

    [ruby]
    symbol = " "

    [rust]
    symbol = "󱘗 "

    [scala]
    symbol = " "

    [swift]
    symbol = " "

    [zig]
    symbol = " "

    [gradle]
    symbol = " "

  '';

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
