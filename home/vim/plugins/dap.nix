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
      autoLoad = true;

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
      autoLoad = true;
    };

    dap-virtual-text = {
      enable = true;
      autoLoad = true;
      settings = {
        enabled_commands = true;
        highlight_changed_variables = true;
        highlight_new_as_changed = true;
        show_stop_reason = true;
        commented = true;
        only_first_definition = true;
        all_references = false;
        clear_on_continue = true;
      };
    };
  };
}
