{
  lualine = {
    enable = true;
    settings.options.globalstatus = true;
    settings.options.disabledFiletypes = {
      statusline = ["dashboard" "alpha"];
    };
    settings.options.theme = {
      normal = {
        a = {
          bg = "#b4befe";
          fg = "#1c1d21";
        };
        b = {
          bg = "nil";
        };
        c = {
          bg = "nil";
        };
        z = {
          bg = "nil";
        };
        y = {
          bg = "nil";
        };
        x = {
          bg = "nil";
        };
      };
    };
    settings.options.componentSeparators = {
      left = "";
      right = " ";
    };
    settings.options.sectionSeparators = {
      left = "";
      right = "";
    };
    settings.sections = {
      lualine_a = [
        {
          __unkeyed = "mode";
          icon.__unkeyed = "";
          separator = {
            left = "";
            right = "";
          };
        }
      ];
      lualine_b = [
        {
          __unkeyed = "branch";
          icon.__unkeyed = "";
          separator = {
            left = "";
            right = "";
          };
          color = {
            fg = "#1c1d21";
            bg = "#7d83ac";
          };
        }
      ];
      lualine_c = [
        {
          __unkeyed = "diagnostic";
          symbols = {
            error = " ";
            warn = " ";
            info = " ";
            hint = "󰝶 ";
          };
        }
        {
          __unkeyed = "filetype";
          separator = {
            left = "";
            right = "";
          };
          icon_only = true;
          padding = {
            left = 1;
            right = 0;
          };
        }
        {
          __unkeyed = "filename";
          symbols = {
            modified = "  ";
            readonly = "";
            unnamed = "";
          };
        }
      ];
      lualine_x = [
        "diff"
      ];
      lualine_y = [
        {
          __unkeyed = "progress";
          icon.__unkeyed = "";
          color = {
            fg = "#1c1d21";
            bg = "#f2cdcd";
          };
        }
      ];
      lualine_z = [
        {
          __unkeyed = "location";
          color = {
            fg = "#1c1d21";
            bg = "#f2cdcd";
          };
        }
      ];
    };
  };
}
