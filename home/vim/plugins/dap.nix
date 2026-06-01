{pkgs}: let
  codelldbPath = "${pkgs.vscode-extensions.vadimcn.vscode-lldb}/share/vscode/extensions/vadimcn.vscode-lldb/adapter/codelldb";
  debugserverPath = "/Library/Developer/CommandLineTools/Library/PrivateFrameworks/LLDB.framework/Versions/A/Resources/debugserver";
  rustLldbEtc = "${pkgs.rustc-unwrapped}/lib/rustlib/etc";
  rustLldbInitCommands = [
    "settings set target.process.thread.step-avoid-regexp '^<?(std|core|alloc)::'"
    "command script import '${rustLldbEtc}/lldb_lookup.py'"
    "command source -s true '${rustLldbEtc}/lldb_commands'"
  ];
in {
  plugins = {
    dap = {
      enable = true;
      lazyLoad.settings = {
        before = ''
          function()
            vim.cmd.packadd("nvim-dap-ui")
            vim.cmd.packadd("nvim-dap-virtual-text")
          end
        '';
        keys = [
          {
            __unkeyed-1 = "<leader>db";
            __unkeyed-2 = "<cmd>lua require('config.dap').restore_pending_breakpoints(); require('dap').toggle_breakpoint()<cr>";
            desc = "Toggle debug breakpoint";
          }
          {
            __unkeyed-1 = "<leader>dA";
            __unkeyed-2 = "<cmd>lua require('config.dap').restore_pending_breakpoints(); require('dap').clear_breakpoints()<cr>";
            desc = "Clear all debug breakpoints";
          }
          {
            __unkeyed-1 = "<leader>dv";
            __unkeyed-2 = "<cmd>lua require('config.dap').restore_pending_breakpoints(); require('config.dap').pick_breakpoints()<cr>";
            desc = "Search debug breakpoints";
          }
          {
            __unkeyed-1 = "<leader>dc";
            __unkeyed-2 = "<cmd>lua require('config.dap').restore_pending_breakpoints(); require('dap').continue()<cr>";
            desc = "Start or continue debugging";
          }
          {
            __unkeyed-1 = "<leader>dp";
            __unkeyed-2 = "<cmd>lua require('config.dap').restore_pending_breakpoints(); require('dap').continue()<cr>";
            desc = "Play until next breakpoint";
          }
          {
            __unkeyed-1 = "<leader>dj";
            __unkeyed-2 = "<cmd>lua require('config.dap').restore_pending_breakpoints(); require('dap').step_into()<cr>";
            desc = "Step into";
          }
          {
            __unkeyed-1 = "<leader>dl";
            __unkeyed-2 = "<cmd>lua require('config.dap').restore_pending_breakpoints(); require('dap').step_over()<cr>";
            desc = "Step over";
          }
          {
            __unkeyed-1 = "<leader>dk";
            __unkeyed-2 = "<cmd>lua require('config.dap').restore_pending_breakpoints(); require('dap').step_out()<cr>";
            desc = "Step out";
          }
          {
            __unkeyed-1 = "<leader>dh";
            __unkeyed-2 = "<cmd>lua require('config.dap').restore_pending_breakpoints(); require('dap').step_back()<cr>";
            desc = "Step back";
          }
          {
            __unkeyed-1 = "<leader>dt";
            __unkeyed-2 = "<cmd>lua require('config.dap').restore_pending_breakpoints(); require('dapui').toggle()<cr>";
            desc = "Toggle debug UI";
          }
          {
            __unkeyed-1 = "<leader>dx";
            __unkeyed-2 = "<cmd>lua require('config.dap').restore_pending_breakpoints(); require('dap').terminate()<cr>";
            desc = "Terminate debugging";
          }
        ];
      };

      adapters.executables.codelldb = {
        command = codelldbPath;
        options = {
          env = {
            LLDB_DEBUGSERVER_PATH = debugserverPath;
          };
        };
      };

      configurations.rust = [
        {
          type = "codelldb";
          request = "launch";
          name = "Launch Rust executable";
          program.__raw = "require('config.dap').pick_rust_executable";

          cwd = "\${workspaceFolder}";
          initCommands = rustLldbInitCommands;
          stopOnEntry = false;
        }

        {
          type = "codelldb";
          request = "attach";
          name = "Attach to process";
          pid.__raw = "require('dap.utils').pick_process";
          cwd = "\${workspaceFolder}";
          initCommands = rustLldbInitCommands;
        }
      ];

      extensionConfigLua = ''
        do
          local dap = require("dap")
          local dapui = require("dapui")

          dapui.setup()
          require("nvim-dap-virtual-text").setup({
            enabled_commands = true,
            highlight_changed_variables = true,
            highlight_new_as_changed = true,
            show_stop_reason = true,
            commented = true,
            only_first_definition = true,
            all_references = false,
            clear_on_continue = true,
          })

          dap.listeners.before.attach.dapui_config = function()
            dapui.open()
          end
          dap.listeners.before.launch.dapui_config = function()
            dapui.open()
          end
          dap.listeners.before.event_terminated.dapui_config = function()
            dapui.close()
          end
          dap.listeners.before.event_exited.dapui_config = function()
            dapui.close()
          end
        end
      '';
    };

    dap-ui = {
      enable = true;
      autoLoad = false;
      callSetup = false;
    };

    dap-virtual-text = {
      enable = true;
      autoLoad = false;
      callSetup = false;
    };
  };
}
