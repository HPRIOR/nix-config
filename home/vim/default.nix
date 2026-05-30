{
  inputs,
  pkgs,
  config,
  ...
}: let
  keymaps = import ./keymap.nix;
  plugins = import ./plugins {inherit pkgs config;};
  options = import ./options.nix;
  mermaidChromePath = "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome";
  mermaidPuppeteerConfig = pkgs.writeText "mermaid-puppeteer-config.json" (builtins.toJSON {
    executablePath = mermaidChromePath;
    headless = true;
  });
  mermaidCliPackage =
    if pkgs.stdenv.isDarwin
    then
      pkgs.writeShellScriptBin "mmdc" ''
        exec ${pkgs.mermaid-cli}/bin/mmdc -p ${mermaidPuppeteerConfig} "$@"
      ''
    else pkgs.mermaid-cli;
in {
  imports = [inputs.nixvim.homeModules.nixvim ./ideavim.nix];

  xdg.configFile."nvim/lua".source = ./lua;

  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };
  programs.nixvim =
    {
      enable = true;
      nixpkgs.useGlobalPackages = true;
      dependencies.imagemagick.enable = true;
      performance = {
        combinePlugins.enable = true;
        # Keep query-providing plugins standalone to avoid buildEnv path conflicts.
        combinePlugins.standalonePlugins = ["nvim-treesitter" "blink.cmp" "smart-splits" "leap.nvim" "mini.nvim" "snacks.nvim"];
        byteCompileLua = {
          enable = true;
          configs = true;
          initLua = true;
          nvimRuntime = true;
          plugins = true;
        };
      };
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;
      colorschemes.kanagawa = {
        enable = true;
        lazyLoad.enable = true;
      };
      extraConfigLuaPre = ''
        do
          local original_deprecate = vim.deprecate
          local suppressed_deprecations = {
            ["vim.lsp.with()"] = true,
            ["vim.validate{<table>}"] = true,
          }

          vim.deprecate = function(name, ...)
            if suppressed_deprecations[name] then
              return nil
            end

            return original_deprecate(name, ...)
          end
        end
      '';
      extraConfigLua = ''
        require("yank_reference")
        require("config").setup()
      '';
      keymaps = keymaps;
      extraPackages = [
        # Picker deps
        pkgs.ripgrep
        pkgs.fzf
        # diagram rendering
        mermaidCliPackage
        # checkhealth deps
        pkgs.tree-sitter
        pkgs.ghostscript
        # formatters requred by conform
        pkgs.alejandra
        pkgs.prettierd
        pkgs.prettier
        pkgs.black
        pkgs.stylua
        pkgs.yamlfmt
        pkgs.rustfmt
        pkgs.shfmt
        pkgs.jq
        pkgs.ron-lsp
        # pkgs.ocamlPackages.ocamlformat
      ];

      globals.mapleader = " ";
      globals.maplocalleader = " ";
    }
    // plugins
    // options;
}
