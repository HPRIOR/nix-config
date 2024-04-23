let
  gpt_commands = {
    add_tests = {
      type = "chat";
      opts = {
        template = "Implement tests for the following code.\n\nCode:\n```{{filetype}}\n{{input}}\n```\n\nTests:\n```{{filetype}}";
        strategy = "append";
        params = {
          model = "gpt-3.5-turbo";
          stop = ["```"];
        };
      };
    };
    add_comments = {
      type = "chat";
      opts = {
        template = "Add comments to the code below explaining what the code does (never how it does it)\n\nCode:\n```{{filetype}}\n{{input}}\n```\n\Commented Code:\n```{{filetype}}";
        strategy = "edit";
        params = {
          model = "gpt-4";
          stop = ["```"];
        };
      };
    };
    explain_code = {
      type = "chat";
      opts = {
        title = " Explain Code";
        template = "Explain the following code:\n\nCode:\n```{{filetype}}\n{{input}}\n```\n\nUse markdown format.\nHere's what the above code is doing:\n```";
        strategy = "display";
        params = {
          model = "gpt-3.5-turbo";
          stop = ["```"];
        };
      };
    };
    fix_bugs = {
      type = "chat";
      opts = {
        template = "Fix bugs in the below code\n\nCode:\n```{{filetype}}\n{{input}}\n```\n\nFixed code:\n```{{filetype}}";
        strategy = "edit";
        params = {
          model = "gpt-3.5-turbo";
          stop = ["```"];
        };
      };
    };
    grammar_correction = {
      type = "chat";
      opts = {
        template = "Correct this to standard English:\n\n{{input}}";
        strategy = "replace";
        params = {
          model = "gpt-3.5-turbo";
        };
      };
    };
    optimize_code = {
      type = "chat";
      opts = {
        template = "Optimize the following code.\n\nCode:\n```{{filetype}}\n{{input}}\n```\n\nOptimized version:\n```{{filetype}}";
        strategy = "edit";
        params = {
          model = "gpt-3.5-turbo";
          stop = ["```"];
        };
      };
    };
    summarize = {
      type = "chat";
      opts = {
        template = "Summarize the following text.\n\nText:\n\"\"\"\n{{input}}\n\"\"\"\n\nSummary:";
        strategy = "edit";
        params = {
          model = "gpt-3.5-turbo";
        };
      };
    };
    translate = {
      type = "chat";
      opts = {
        template = "Translate this into English:\n\n{{input}}";
        strategy = "replace";
        params = {
          model = "gpt-3.5-turbo";
          temperature = 0.3;
        };
      };
    };
    reduce_text = {
      type = "chat";
      opts = {
        template = "Make this text more concise:\n\n{{input}}";
        strategy = "replace";
        params = {
          model = "gpt-3.5-turbo";
          temperature = 0.3;
        };
      };
    };
    # These latter two do not require a json config
    interactive = {};
    chat = {};
  };

  cmdStr = builtins.foldl' (acc: item: acc + "\"" + item + "\"" + ",") "" (builtins.attrNames gpt_commands);
  cmdJson = builtins.toJSON gpt_commands;
in {
  telescope_ext_config = ''
    gpt = {
        title = "Gpt Actions",
        commands = { ${cmdStr} },
        theme = require("telescope.themes").get_dropdown{}
    }
  '';
  telescope_gpt_cmds = cmdJson;
}
