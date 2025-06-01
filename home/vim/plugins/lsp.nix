{
  rust-packages,
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
      fsautocomplete.enable = true;
      html.enable = true;
      jsonls.enable = true;
      lua_ls.enable = true;
      marksman.enable = true;
      nixd.enable = true;
      ocamlls = {
        enable = true;
        package = pkgs.ocamlPackages.ocaml-lsp;
        cmd = ["${pkgs.ocamlPackages.ocaml-lsp}/bin/ocamllsp" "--stdio"];
      };
      omnisharp.enable = true;
      pyright.enable = true;
      metals.enable = true;
      lemminx.enable = true;
      rust_analyzer = {
        enable = true;
        package = rust-packages.analyzer;
        cargoPackage = rust-packages.cargo;
        rustcPackage = rust-packages.rustc;
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
            fullFunctionSignatures.enable = false;
            callable.snippets = "none";
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
      "<C-a>" = "code_action";
      "<leader>r" = "rename";
    };
    keymaps.diagnostic = {
      "ge" = "goto_next";
      "gE" = "goto_prev";
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
