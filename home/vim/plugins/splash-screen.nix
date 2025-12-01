let
  logo = ''
               III      ~+===~     =+=
              IIIII      +====:   =====
               IIIII      =====  ======
               +IIII7      ====+:====~
                7IIII       =========
          =IIIIIIIIIIIIIIIII,=======      =
         ~IIIIIIIIIIIIIIIIIII =====      +7:
         IIIIIIIIIIIIIIIIIIIII =====     III:
                =====           =====   IIII7
               =====~            ===== IIIII
              :====~             ~=== IIIII
     ::::::::~====+               ~= IIIII??????
    =============+                 ,7IIIIIIIIIIII
    +============?                 IIIIIIIIIIIIII
           ====+,II               7IIII
          =====,IIII             IIIII~
         ===== ~IIIII           ?IIII~
        =====   ?IIII~         ~IIII7
         ===     7IIII:=====================
          +       IIIII ===================
                 IIIIIII =================,
                7IIIIIII7       =====
               7IIII~7IIII       =====
              IIIII~  IIIII      :====+
              7IIII    IIIII      :===+
  '';
in {
  alpha = {
    enable = true;
    settings.layout = [
      {
        type = "padding";
        val = 4;
      }
      {
        opts = {
          hl = "AlphaHeader";
          position = "center";
        };
        type = "text";
        val = logo;
      }
      {
        type = "padding";
        val = 2;
      }
      {
        type = "group";
        val = let
          mkButton = shortcut: cmd: val: hl: {
            type = "button";
            inherit val;
            opts = {
              inherit hl shortcut;
              keymap = [
                "n"
                shortcut
                cmd
                {}
              ];
              position = "center";
              cursor = 0;
              width = 40;
              align_shortcut = "right";
              hl_shortcut = "Keyword";
            };
          };
        in [
          (
            mkButton
            "f"
            "<CMD>lua Snacks.picker.files()<CR>"
            "🔍 Find File"
            "Operator"
          )
          (
            mkButton
            "g"
            "<cmd>lua Snacks.picker.grep()<cr>"
            "🔍 Live grep"
            "Operator"
          )
          (
            mkButton
            "t"
            ":Neotree toggle<CR>"
            "  Open tree"
            "Operator"
          )
          (
            mkButton
            "q"
            "<CMD>qa<CR>"
            "💣 Quit Neovim"
            "String"
          )
        ];
      }
      {
        type = "padding";
        val = 2;
      }
    ];
  };
}
