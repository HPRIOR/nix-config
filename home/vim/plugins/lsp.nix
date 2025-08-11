{
  pkgs,
  ...
}: {
  lsp = {
    enable = true;
    servers = {
      bashls.enable = true;
      clangd.enable = true;
      cmake.enable = true;
      dockerls.enable = true;
      elmls.enable = true;
      eslint.enable = true;
      fsautocomplete.enable = true;
      html.enable = true;
      jsonls.enable = true;
      lua_ls.enable = true;
      marksman.enable = true;
      nixd.enable = true;
      ocamlls = {
        enable = true;
        package = null; # Needs to be overriden in project flakes
        cmd = ["ocamllsp" "--stdio"];
      };
      omnisharp.enable = true;
      pyright.enable = true;
      metals.enable = true;
      lemminx.enable = true;
      rust_analyzer = {
        enable = true;
        # Don't specify package - use the one from PATH
        package = null;
        # Let it find rust-analyzer in PATH
        cmd = ["rust-analyzer"];
        # Don't install cargo/rustc - use from environment
        installCargo = false;
        installRustc = false;
        settings = {
          files.excludeDirs = [".direnv" ".cargo"];
          check.command = "clippy";
          cargo.features = "all";
          check.features = "all";
          check.extraArgs = [
            "--"
            "--no-deps"
            "-Dclippy::correctness"
            "-Dclippy::complexity"
            "-Wclippy::perf"
            "-Wclippy::pedantic"
          ];
          completion = {
            fullFunctionSignatures.enable = true;
            callable.snippets = "fill_arguments";
          };
        };
      };
      yamlls.enable = true;
      elixirls.enable = true;
      ts_ls.enable = true;
      tailwindcss = {
        enable = true;
        autostart = false;
      };
      jdtls.enable = true;
    };
    keymaps.lspBuf = {
      "K" = "hover";
      "<leader>r" = "rename";
    };
    keymaps.diagnostic = {
      "<leader>d" = "open_float";
    };
  };

  lspkind = {
    enable = true;
    extraOptions = {
      maxwidth = 50;
      ellipsis_char = "...";
    };
  };
}
