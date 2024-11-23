{
  pkgs,
  rust-packages,
}: {
  lsp = {
    enable = true;
    onAttach = ''
      if client.server_capabilities.documentSymbolProvider then
        require("nvim-navic").attach(client, bufnr)
      end
    '';
    servers = {
      bashls.enable = true;
      clangd.enable = true;
      cmake.enable = true;
      dockerls.enable = true;
      elmls.enable = true;
      fsautocomplete.enable = true;
      html.enable = true;
      jsonls.enable = true;
      lua-ls.enable = true;
      marksman.enable = true;
      nixd.enable = true;
      ocamllsp.enable = true;
      omnisharp.enable = true;
      pyright.enable = true;
      metals.enable = true;
      lemminx.enable = true;
      rust-analyzer = {
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
        };
      };
      yamlls.enable = true;
      elixirls.enable = true;
      tsserver.enable = true;
      tailwindcss.enable = true;
    };
    keymaps.lspBuf = {
      "gD" = "references";
      "gt" = "type_definition";
      "gi" = "implementation";
      "K" = "hover";
      "<leader>a" = "code_action";
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
