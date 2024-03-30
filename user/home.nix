{ config, pkgs, ... }:
let 
	userName = "harryp";
	homeDir =  "/home/harryp";
	dotFiles = "${homeDir}/.dotfiles";
	aliases = {
		# nix editing 
		editconfig = "nvim ${dotFiles}/system/configuration.nix";
		buildconfig = "sudo nixos-rebuild switch --flake ${dotFiles}";
		edithome = "nvim ${dotFiles}/user/home.nix";
		buildhome = "home-manager switch --flake ${dotFiles}";
		editnix = "nvim ${dotFiles}";

		# lazy
		lzg = "lazygit";
		lzd = "lazydocker";

		# zsh
		sourcezsh = "source ${homeDir}/.zshrc";

		# modern replacements
		diff = "difft";
		cat = "bat";
		ls = "exa";
		ll = "exa -l";
		lla = "exa -la";
		la = "exa -a";
		changes = "git diff */**";

        copy = "wl-copy";
        paste = "wl-paste";

	};

    # scripts
    nix-build = import ./scripts/nix-build.nix { inherit pkgs; };
in

{
  home.username = userName;
  home.homeDirectory = homeDir;
  home.stateVersion = "23.05"; 
  home.packages = [
    nix-build
  ];
  home.file = { };
  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    TERMCMD = "${pkgs.kitty}/bin/kitty";
  };

  xdg = {
    enable = true;

    userDirs = {
      enable = true;
      createDirectories = true;
    };
  };


  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  programs.bash = {
	enable = false;
	shellAliases = aliases;
   };

  programs.zsh = {
	enable = true;
	enableCompletion = true;
	enableAutosuggestions = true;
	syntaxHighlighting.enable = true;
	oh-my-zsh = {
		enable = true;
		plugins = [ "git" "sudo" "copypath" "copyfile" "history" ];
		theme = "robbyrussell";
	};
	shellAliases = aliases; 
	initExtra = ''
		eval "$(zoxide init zsh)"
	'';
   };
 
  programs.zoxide = {
	enable = true;
	options = [];
  };
  programs.neovim = {
	enable = true;
	defaultEditor = true;
	viAlias = true;
	vimAlias = true;
	vimdiffAlias = true;
	extraLuaConfig = '' 
		${builtins.readFile ./neovim/options.lua}
	'';
    plugins = with pkgs.vimPlugins; [
        nvim-lspconfig
        nvim-treesitter.withAllGrammars
        plenary-nvim
        gruvbox-material
    ];
  };

  programs.git = {
	enable = true;
	package = pkgs.gitAndTools.gitFull;
	userName = "Harry Joseph Prior";
	userEmail = "harryjosephprior@protonmail.com";
	extraConfig = {
		core.autocrlf = "input";
		merge.conflictstyle = "diff3";
		diff.colorMoved = "default";

	};
	delta = {
		enable = true;	
		options = {
			features = "side-by-side line-numbers decorations";
			whitespace-error-style = "22 reverse";
			navigate = "true";

		};
	};
  };


  wayland.windowManager.hyprland = {
    enable = true;
    extraConfig = ''
        # Required for mouse to render
        env = WLR_NO_HARDWARE_CURSORS,1

        # Startup applications
        exec-once = waybar
        exec-once = blueman-applet

        # Monitor
        monitor=,preferred,auto,1
        monitor=DP-3,3440x1440@74.983002,0x0,1
        monitor=DP-2,2560x2880@29.969999,3440x0,1.5
        monitor=DP-1,3840x2160,-1440x-400,1.5,transform,1
        monitor=HDMI-A-1,disable


        # Key bindings
        $mainMod = SUPER
        $shiftMod = SUPERSHIFT
        bind = $mainMod, Return, exec, kitty
        bind = $shiftMod, Q, killactive

        bind = $mainMod, H, movefocus, l
        bind = $mainMod, J, movefocus, d
        bind = $mainMod, K, movefocus, u
        bind = $mainMod, L, movefocus, r

        bind = $shiftMod, H, movewindow, l
        bind = $shiftMod, J, movewindow, d
        bind = $shiftMod, K, movewindow, u
        bind = $shiftMod, L, movewindow, r

        bind = $mainMod, SPACE, exec, rofi -show drun
        bind = $mainMod, F, fullscreen, 0

        bindm = $mainMod, mouse:272, movewindow
        bindm = $mainMod, mouse:273, resizewindow

        # Switch to submap called resize
        bind=$mainMod,R,submap,resize

        submap=resize
        binde=,L,resizeactive,30 0
        binde=,H,resizeactive,-30 0
        binde=,K,resizeactive,0 -30
        binde=,J,resizeactive,0 30

        # use reset to go back to the global submap
        bind=,escape,submap,reset 
        bind=$mainMod,R,submap,reset 
        bind=,return,submap,reset 

        # Reset submap, normal keybindings resume
        submap=reset


        input {
            kb_layout = gb
            kb_options = caps:swapescape
        }

        misc {
            disable_splash_rendering = true
            disable_hyprland_logo = true
        }

        decoration {
            rounding = 2
            blur {
                enabled = true
                size = 3
                passes = 1
                vibrancy = 0.1696
            }
        }

        '';
    };

}
