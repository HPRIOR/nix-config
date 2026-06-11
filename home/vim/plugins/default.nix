{
  pkgs,
  config,
}: let
  lsp = import ./lsp.nix {inherit pkgs;};
  autocomplete = import ./auto-completion.nix pkgs;
  dap = import ./dap.nix {inherit pkgs;};
  lualine = import ./lualine.nix;
  splash-screen = import ./splash-screen.nix;
in {
  plugins =
    {
      actions-preview = {
        enable = true;
        lazyLoad.settings.keys = [
          {
            __unkeyed-1 = "<c-a>";
            __unkeyed-2 = "<cmd>lua require('actions-preview').code_actions()<cr>";
            desc = "Show code actions";
            mode = [
              "n"
              "i"
            ];
          }
        ];
        settings = {
          backend = ["snacks" "minipick"];
          snacks = {
            layout = {preset = "dropdown";};
          };
        };
      };
      lz-n = {
        enable = true;
        autoLoad = true;
      };
      which-key = {
        enable = true;
        settings = {
          preset = "helix";
          triggers = [
            {
              __unkeyed = "<leader>T";
              mode = "n";
            }
          ];
          win = {
            no_overlap = false;
          };
        };
      };
      scrollview = {
        enable = true;
        lazyLoad.settings.event = "DeferredUIEnter";
      };
      aerial = {
        enable = true;
        lazyLoad.settings.cmd = [
          "AerialNavToggle"
          "AerialToggle"
        ];
      };
      dropbar.enable = true;
      fidget = {
        enable = true;
        lazyLoad.settings.event = "LspAttach";
      };
      smear-cursor = {
        enable = false;
        settings = {
          stiffness = 0.8;
          trailing_stiffness = 0.5;
          distance_stop_animating = 0.5;
        };
      };
      smart-splits = {
        enable = true;
        lazyLoad.settings.keys = [
          {
            __unkeyed-1 = "<c-h>";
            __unkeyed-2 = "<cmd>lua require('smart-splits').resize_left()<cr>";
            desc = "Resize left";
          }
          {
            __unkeyed-1 = "<c-j>";
            __unkeyed-2 = "<cmd>lua require('smart-splits').resize_down()<cr>";
            desc = "Resize down";
          }
          {
            __unkeyed-1 = "<c-k>";
            __unkeyed-2 = "<cmd>lua require('smart-splits').resize_up()<cr>";
            desc = "Resize up";
          }
          {
            __unkeyed-1 = "<c-l>";
            __unkeyed-2 = "<cmd>lua require('smart-splits').resize_right()<cr>";
            desc = "Resize right";
          }
        ];
      };
      colorful-winsep.enable = true;
      bullets = {
        enable = true;
        lazyLoad.settings.ft = [
          "markdown"
          "text"
          "gitcommit"
          "scratch"
        ];
        settings = {
          enable_in_empty_buffers = 0;
          enabled_file_types = [
            "markdown"
            "text"
            "gitcommit"
            "scratch"
          ];
          nested_checkboxes = 0;
        };
      };
      gitsigns = {
        enable = true;
        lazyLoad.settings.event = [
          "BufReadPre"
          "BufNewFile"
        ];
      };
      codediff = {
        enable = true;
        lazyLoad.settings.cmd = "CodeDiff";
        settings = {
          keymaps = {
            view = {
              next_hunk = "gh";
              prev_hunk = "gH";
            };
          };
        };
      };
      wrapping = {
        enable = true;
        lazyLoad.settings.event = "BufReadPost";
        settings = {
          create_commands = false;
          create_keymaps = false;
        };
      };
      trouble = {
        enable = true;
        lazyLoad.settings.cmd = "Trouble";
      };
      vim-matchup = {
        enable = true;
        lazyLoad.settings.event = "BufReadPost";
      };
      tiny-inline-diagnostic.enable = false;
      auto-session = {
        enable = true;
        settings = {
          session_lens = {
            load_on_setup = false;
          };
          pre_save_cmds = [
            {
              __raw = ''
                function(session_name)
                  require("config.dap").save_breakpoints(session_name)
                end
              '';
            }
          ];
          post_restore_cmds = [
            {
              __raw = ''
                function(session_name)
                  require("config.dap").restore_breakpoints(session_name)
                end
              '';
            }
          ];
        };
      };
      guess-indent = {
        enable = true;
        lazyLoad.settings.event = [
          "BufReadPre"
          "BufNewFile"
        ];
      };
      colorizer = {
        enable = true;
        lazyLoad.settings.event = [
          "BufReadPost"
          "BufNewFile"
        ];
      };
      web-devicons.enable = true;
      mini.enable = true;
      diagram = {
        enable = true;
        lazyLoad.settings.ft = [
          "markdown"
          "mermaid"
        ];
        settings = {
          renderer_options = {
            mermaid = {
              theme = "dark";
              background = "transparent";
            };
          };
        };
      };
      image = {
        enable = true;
        lazyLoad.settings.ft = "markdown";
        settings = {
          backend = "kitty";
          processor = "magick_cli";
          integrations = {
            markdown = {
              enabled = true;
              clear_in_insert_mode = false;
              download_remote_images = true;
              only_render_image_at_cursor = false;
              floating_windows = false;
              filetypes = ["markdown"];
            };
          };
        };
      };
      render-markdown = {
        enable = true;
        lazyLoad.settings.ft = "markdown";

        settings = {
          code = {
            border = "none";
          };

          link = {
            enabled = true;
          };
          file_types = ["markdown"];
        };
      };
      helpview = {
        enable = true;
        lazyLoad.settings.ft = "help";
      };
      snacks = {
        enable = true;
        settings = {
          animate = {enabled = true;};
          bigfile = {enabled = true;};
          indent = {
            enabled = false;
            animate = {enabled = false;};
          };
          lazygit = {enabled = true;};
          notifier = {
            enabled = true;
            timeout = 3000;
          };
          picker = {enabled = true;};
          quickfile = {enabled = true;};
          scroll = {enabled = true;};
          toggle = {};
          zen = {
            enabled = true;
            toggles = {
              dim = false;
            };
            win = {
              style = "zen";
              backdrop = {
                transparent = false;
                blend = 0;
              };
              wo = {
                wrap = true;
              };
            };
          };
          terminal = {
            enabled = true;
          };
        };
      };
      nvim-autopairs.enable = true;
      treesitter-context.enable = false;
      treesitter-textobjects.enable = true;
      treesitter = {
        settings = {
          indent = {
            enable = true;
            # disable = ["ocaml"];
          };
          highlight.enable = true;
        };
        enable = true;
      };
      # Code formatting
      conform-nvim = {
        enable = true;
        lazyLoad.settings.keys = [
          {
            __unkeyed-1 = "gf";
            __unkeyed-2 = "<cmd>lua require('conform').format({ lsp_fallback = true })<cr>";
            desc = "Format buffer or selection";
            mode = [
              "n"
              "v"
            ];
          }
        ];
        settings.notifyOnError = true;
        settings.formatters_by_ft = {
          html = {
            __unkeyed-1 = "prettierd";
            __unkeyed-2 = "prettier";
            timeout_ms = 2000;
            stop_after_first = true;
          };
          css = {
            __unkeyed-1 = "prettierd";
            __unkeyed-2 = "prettier";
            timeout_ms = 2000;
            stop_after_first = true;
          };
          json = ["jq"];
          javascript = {
            __unkeyed-1 = "prettierd";
            __unkeyed-2 = "prettier";
            timeout_ms = 2000;
            stop_after_first = true;
          };
          javascriptreact = {
            __unkeyed-1 = "prettierd";
            __unkeyed-2 = "prettier";
            timeout_ms = 2000;
            stop_after_first = true;
          };
          typescript = {
            __unkeyed-1 = "prettierd";
            __unkeyed-2 = "prettier";
            timeout_ms = 2000;
            stop_after_first = true;
          };
          typescriptreact = {
            __unkeyed-1 = "prettierd";
            __unkeyed-2 = "prettier";
            timeout_ms = 2000;
            stop_after_first = true;
          };
          python = ["black"];
          lua = ["stylua"];
          nix = ["alejandra"];
          markdown = {
            __unkeyed-1 = "prettierd";
            __unkeyed-2 = "prettier";
            timeout_ms = 2000;
            stop_after_first = true;
          };
          yaml = ["yamlfmt"];
          rust = ["rustfmt"];
          sh = ["shfmt"];
          ocaml = ["ocamlformat"];
        };
      };

      leap = {
        enable = true;
        lazyLoad.settings.keys = [
          {
            __unkeyed-1 = "s";
            __unkeyed-2 = "<cmd>lua require('leap').leap({ target_windows = { vim.fn.win_getid() }})<cr>";
            desc = "Leap up/down in window";
            mode = [
              "n"
              "x"
              "o"
            ];
          }
        ];
      };
      illuminate.enable = true;
      vim-surround.enable = true;
      comment.enable = true;
      neo-tree = {
        enable = true;
        lazyLoad.settings.cmd = "Neotree";
      };
      codecompanion = {
        enable = true;
        lazyLoad.settings.cmd = [
          "CodeCompanion"
          "CodeCompanionActions"
          "CodeCompanionChat"
          "CodeCompanionCmd"
        ];
        settings = {
          adapters = {
            http = {
              openai.__raw = ''
                function()
                  return require("codecompanion.adapters").extend("openai", {
                    env = {
                      api_key = "OPENAI_API_KEY",
                    },
                    schema = {
                      model = {
                        default = "gpt-5.2",
                      },
                    },
                  })
                end
              '';
            };
          };
          strategies = {
            chat = {
              adapter = {
                name = "openai";
                model = "gpt-5.2";
              };
            };
            inline = {
              adapter = {
                name = "openai";
                model = "gpt-5.2";
              };
            };
            cmd = {
              adapter = {
                name = "openai";
                model = "gpt-5.2";
              };
            };
          };
        };
      };
    }
    // dap.plugins
    // lsp
    // autocomplete
    // lualine
    // splash-screen;

  extraPlugins = with pkgs.vimPlugins; [
    nvim-window-picker
  ];
}
