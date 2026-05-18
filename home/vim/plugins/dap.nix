{pkgs}: let
  codelldbPath = "${pkgs.vscode-extensions.vadimcn.vscode-lldb}/share/vscode/extensions/vadimcn.vscode-lldb/adapter/codelldb";
  debugserverPath = "/Library/Developer/CommandLineTools/Library/PrivateFrameworks/LLDB.framework/Versions/A/Resources/debugserver";
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

          program.__raw = ''
            function()
              local dap = require("dap")
              local path = vim.fn.input({
                prompt = "Path to executable: ",
                default = vim.fn.getcwd() .. "/target/debug/",
                completion = "file",
              })

              if path == nil or path == "" then
                return dap.ABORT
              end

              path = vim.fn.expand(path)
              vim.notify("DAP launching executable: " .. path, vim.log.levels.INFO)

              if vim.fn.executable(path) ~= 1 then
                vim.notify("DAP executable does not exist or is not executable: " .. path, vim.log.levels.ERROR)
                return dap.ABORT
              end

              return path
            end
          '';

          cwd = "\${workspaceFolder}";
          stopOnEntry = false;
        }

        {
          type = "codelldb";
          request = "attach";
          name = "Attach to process";
          pid.__raw = "require('dap.utils').pick_process";
          cwd = "\${workspaceFolder}";
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
  };
}
