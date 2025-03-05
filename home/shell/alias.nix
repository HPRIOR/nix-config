{
  pkgs,
  settings,
}: let
  isDarwin = pkgs.stdenv.isDarwin;
  homeDir = settings.homeDir;
  dotFiles = settings.dotFiles;
in {
  shared = rec {
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
    changes = "git diff";
    status = "git status";
    tree = "exa -T --icons=always --group-directories-last --git-ignore";

    copy =
      if isDarwin
      then "pbcopy"
      else "wl-copy";

    paste =
      if isDarwin
      then "pbpaste"
      else "wl-paste";

    pdate = "date -u +%Y-%m-%dT%H_%M_%S";

    shell = "nix-shell -p";

    direnv-init = ''
      echo 'if ! has nix_direnv_version || ! nix_direnv_version 3.0.4; then
        source_url "https://raw.githubusercontent.com/nix-community/nix-direnv/3.0.4/direnvrc" \
                   "sha256-DzlYZ33mWF/Gs8DDeyjr8mnVmQGx7ASYqA5WlxwvBG4="
      fi

      use flake' > .envrc
    '';
  };

  linux = {
    nap = "systemctl suspend";
    buildwork = "sudo nixos-rebuild switch --flake ${dotFiles}#work";

    cap = "grim -g \"$(slurp)\" $HOME/Pictures/Screenshots/$(date +'%s_grim.png')";
    scap = "grim -g \"$(slurp -o)\" $HOME/Pictures/Screenshots/$(date +'%s_grim.png')";
  };
}
