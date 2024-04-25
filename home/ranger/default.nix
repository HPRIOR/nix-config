{settings, ...}: let
  pager = "bat --paging always";
  editor = "nvim";
in {
  home.file."${settings.configDir}/ranger/rifle.conf".text = ''
    #-------------------------------------------
    # Websites
    #-------------------------------------------
    # Rarely installed browsers get higher priority; It is assumed that if you
    # install a rare browser, you probably use it.  Firefox/konqueror/w3m on the
    # other hand are often only installed as fallback browsers.
    ext x?html?, has surf,             X, flag f = surf -- file://"$1"
    ext x?html?, has vimprobable,      X, flag f = vimprobable -- "$@"
    ext x?html?, has vimprobable2,     X, flag f = vimprobable2 -- "$@"
    ext x?html?, has qutebrowser,      X, flag f = qutebrowser -- "$@"
    ext x?html?, has dwb,              X, flag f = dwb -- "$@"
    ext x?html?, has jumanji,          X, flag f = jumanji -- "$@"
    ext x?html?, has luakit,           X, flag f = luakit -- "$@"
    ext x?html?, has uzbl,             X, flag f = uzbl -- "$@"
    ext x?html?, has uzbl-tabbed,      X, flag f = uzbl-tabbed -- "$@"
    ext x?html?, has uzbl-browser,     X, flag f = uzbl-browser -- "$@"
    ext x?html?, has uzbl-core,        X, flag f = uzbl-core -- "$@"
    ext x?html?, has midori,           X, flag f = midori -- "$@"
    ext x?html?, has opera,            X, flag f = opera -- "$@"
    ext x?html?, has firefox,          X, flag f = firefox -- "$@"
    ext x?html?, has seamonkey,        X, flag f = seamonkey -- "$@"
    ext x?html?, has iceweasel,        X, flag f = iceweasel -- "$@"
    ext x?html?, has chromium-browser, X, flag f = chromium-browser -- "$@"
    ext x?html?, has chromium,         X, flag f = chromium -- "$@"
    ext x?html?, has google-chrome,    X, flag f = google-chrome -- "$@"
    ext x?html?, has epiphany,         X, flag f = epiphany -- "$@"
    ext x?html?, has konqueror,        X, flag f = konqueror -- "$@"
    ext x?html?, has elinks,            terminal = elinks "$@"
    ext x?html?, has links2,            terminal = links2 "$@"
    ext x?html?, has links,             terminal = links "$@"
    ext x?html?, has lynx,              terminal = lynx -- "$@"
    ext x?html?, has w3m,               terminal = w3m "$@"

    #-------------------------------------------
    # Misc
    #-------------------------------------------
    # Define the "editor" for text files as first action
    mime ^text,  label editor = ${editor} "$@"
    mime ^text,  label pager  = ${pager} "$@"
    !mime ^text, label editor, ext xml|json|csv|tex|py|pl|rb|js|sh|php|rs|txt|md|lua|yaml = ${editor} "$@"
    !mime ^text, label pager,  ext xml|json|csv|tex|py|pl|rb|js|sh|php = ${pager} "$@"

    ext 1                         = man "$1"
    ext s[wmf]c, has zsnes, X     = zsnes "$1"
    ext s[wmf]c, has snes9x-gtk,X = snes9x-gtk "$1"
    ext nes, has fceux, X         = fceux "$1"
    ext exe                       = wine "$1"
    name ^[mM]akefile$            = make

    #--------------------------------------------
    # Scripts
    #-------------------------------------------
    ext py  = python -- "$1"
    ext pl  = perl -- "$1"
    ext rb  = ruby -- "$1"
    ext js  = node -- "$1"
    ext sh  = sh -- "$1"
    ext php = php -- "$1"

    #--------------------------------------------
    # Audio without X
    #-------------------------------------------
    mime ^audio|ogg$, terminal, has mpv      = mpv -- "$@"
    mime ^audio|ogg$, terminal, has mplayer2 = mplayer2 -- "$@"
    mime ^audio|ogg$, terminal, has mplayer  = mplayer -- "$@"
    ext midi?,        terminal, has wildmidi = wildmidi -- "$@"

    #--------------------------------------------
    # Video/Audio with a GUI
    #-------------------------------------------
    mime ^video|audio, has gmplayer, X, flag f = gmplayer -- "$@"
    mime ^video|audio, has smplayer, X, flag f = smplayer "$@"
    mime ^video,       has mpv,      X, flag f = mpv -- "$@"
    mime ^video,       has mpv,      X, flag f = mpv --fs -- "$@"
    mime ^video,       has mplayer2, X, flag f = mplayer2 -- "$@"
    mime ^video,       has mplayer2, X, flag f = mplayer2 -fs -- "$@"
    mime ^video,       has mplayer,  X, flag f = mplayer -- "$@"
    mime ^video,       has mplayer,  X, flag f = mplayer -fs -- "$@"
    mime ^video|audio, has vlc,      X, flag f = vlc -- "$@"
    mime ^video|audio, has totem,    X, flag f = totem -- "$@"
    mime ^video|audio, has totem,    X, flag f = totem --fullscreen -- "$@"

    #--------------------------------------------
    # Video without X
    #-------------------------------------------
    mime ^video, terminal, !X, has mpv       = mpv -- "$@"
    mime ^video, terminal, !X, has mplayer2  = mplayer2 -- "$@"
    mime ^video, terminal, !X, has mplayer   = mplayer -- "$@"

    #-------------------------------------------
    # Documents
    #-------------------------------------------
    ext pdf, has llpp,     X, flag f = llpp "$@"
    ext pdf, has zathura,  X, flag f = zathura -- "$@"
    ext pdf, has mupdf,    X, flag f = mupdf "$@"
    ext pdf, has mupdf-x11,X, flag f = mupdf-x11 "$@"
    ext pdf, has apvlv,    X, flag f = apvlv -- "$@"
    ext pdf, has xpdf,     X, flag f = xpdf -- "$@"
    ext pdf, has evince,   X, flag f = evince -- "$@"
    ext pdf, has atril,    X, flag f = atril -- "$@"
    ext pdf, has okular,   X, flag f = okular -- "$@"
    ext pdf, has epdfview, X, flag f = epdfview -- "$@"
    ext pdf, has qpdfview, X, flag f = qpdfview "$@"
    ext pdf, has open,     X, flag f = open "$@"

    ext docx?, has catdoc,       terminal = catdoc -- "$@" | ${pager}

    ext                        sxc|xlsx?|xlt|xlw|gnm|gnumeric, has gnumeric,    X, flag f = gnumeric -- "$@"
    ext                        sxc|xlsx?|xlt|xlw|gnm|gnumeric, has kspread,     X, flag f = kspread -- "$@"
    ext pptx?|od[dfgpst]|docx?|sxc|xlsx?|xlt|xlw|gnm|gnumeric, has libreoffice, X, flag f = libreoffice "$@"
    ext pptx?|od[dfgpst]|docx?|sxc|xlsx?|xlt|xlw|gnm|gnumeric, has soffice,     X, flag f = soffice "$@"
    ext pptx?|od[dfgpst]|docx?|sxc|xlsx?|xlt|xlw|gnm|gnumeric, has ooffice,     X, flag f = ooffice "$@"

    ext djvu, has zathura,X, flag f = zathura -- "$@"
    ext djvu, has evince, X, flag f = evince -- "$@"
    ext djvu, has atril,  X, flag f = atril -- "$@"
    ext djvu, has djview, X, flag f = djview -- "$@"

    ext epub, has ebook-viewer, X, flag f = ebook-viewer -- "$@"
    ext epub, has zathura,      X, flag f = zathura -- "$@"
    ext epub, has mupdf,        X, flag f = mupdf -- "$@"
    ext mobi, has ebook-viewer, X, flag f = ebook-viewer -- "$@"

    ext cbr,  has zathura,      X, flag f = zathura -- "$@"
    ext cbz,  has zathura,      X, flag f = zathura -- "$@"

    #-------------------------------------------
    # Images
    #-------------------------------------------
    mime ^image/svg, has inkscape, X, flag f = inkscape -- "$@"
    mime ^image/svg, has display,  X, flag f = display -- "$@"

    mime ^image, has imv,       X, flag f = imv -- "$@"
    mime ^image, has pqiv,      X, flag f = pqiv -- "$@"
    mime ^image, has sxiv,      X, flag f = sxiv -- "$@"
    mime ^image, has feh,       X, flag f = feh -- "$@"
    mime ^image, has mirage,    X, flag f = mirage -- "$@"
    mime ^image, has ristretto, X, flag f = ristretto "$@"
    mime ^image, has eog,       X, flag f = eog -- "$@"
    mime ^image, has eom,       X, flag f = eom -- "$@"
    mime ^image, has nomacs,    X, flag f = nomacs -- "$@"
    mime ^image, has geeqie,    X, flag f = geeqie -- "$@"
    mime ^image, has gpicview,  X, flag f = gpicview -- "$@"
    mime ^image, has gwenview,  X, flag f = gwenview -- "$@"
    mime ^image, has gimp,      X, flag f = gimp -- "$@"
    ext xcf,                    X, flag f = gimp -- "$@"

    #-------------------------------------------
    # Archives
    #-------------------------------------------

    # avoid password prompt by providing empty password
    ext 7z, has 7z = 7z -p l "$@" | ${pager}
    # This requires atool
    ext ace|ar|arc|bz2?|cab|cpio|cpt|deb|dgc|dmg|gz,     has atool = atool --list --each -- "$@" | ${pager}
    ext iso|jar|msi|pkg|rar|shar|tar|tgz|xar|xpi|xz|zip, has atool = atool --list --each -- "$@" | ${pager}
    ext 7z|ace|ar|arc|bz2?|cab|cpio|cpt|deb|dgc|dmg|gz,  has atool = atool --extract --each -- "$@"
    ext iso|jar|msi|pkg|rar|shar|tar|tgz|xar|xpi|xz|zip, has atool = atool --extract --each -- "$@"

    # Listing and extracting archives without atool:
    ext tar|gz|bz2|xz, has tar = tar vvtf "$1" | ${pager}
    ext tar|gz|bz2|xz, has tar = for file in "$@"; do tar vvxf "$file"; done
    ext bz2, has bzip2 = for file in "$@"; do bzip2 -dk "$file"; done
    ext zip, has unzip = unzip -l "$1" | less
    ext zip, has unzip = for file in "$@"; do unzip -d "''${file%.*}" "$file"; done
    ext ace, has unace = unace l "$1" | less
    ext ace, has unace = for file in "$@"; do unace e "$file"; done
    ext rar, has unrar = unrar l "$1" | less
    ext rar, has unrar = for file in "$@"; do unrar x "$file"; done

    #-------------------------------------------
    # Fonts
    #-------------------------------------------
    mime ^font, has fontforge, X, flag f = fontforge "$@"

    #-------------------------------------------
    # Flag t fallback terminals
    #-------------------------------------------
    # Rarely installed terminal emulators get higher priority; It is assumed that
    # if you install a rare terminal emulator, you probably use it.
    # gnome-terminal/konsole/xterm on the other hand are often installed as part of
    # a desktop environment or as fallback terminal emulators.
    mime ^ranger/x-terminal-emulator, has terminology = terminology -e "$@"
    mime ^ranger/x-terminal-emulator, has kitty = kitty -- "$@"
    mime ^ranger/x-terminal-emulator, has alacritty = alacritty -e "$@"
    mime ^ranger/x-terminal-emulator, has sakura = sakura -e "$@"
    mime ^ranger/x-terminal-emulator, has lilyterm = lilyterm -e "$@"
    #mime ^ranger/x-terminal-emulator, has cool-retro-term = cool-retro-term -e "$@"
    mime ^ranger/x-terminal-emulator, has termite = termite -x '"$@"'
    #mime ^ranger/x-terminal-emulator, has yakuake = yakuake -e "$@"
    mime ^ranger/x-terminal-emulator, has guake = guake -ne "$@"
    mime ^ranger/x-terminal-emulator, has tilda = tilda -c "$@"
    mime ^ranger/x-terminal-emulator, has st = st -e "$@"
    mime ^ranger/x-terminal-emulator, has terminator = terminator -x "$@"
    mime ^ranger/x-terminal-emulator, has urxvt = urxvt -e "$@"
    mime ^ranger/x-terminal-emulator, has pantheon-terminal = pantheon-terminal -e "$@"
    mime ^ranger/x-terminal-emulator, has lxterminal = lxterminal -e "$@"
    mime ^ranger/x-terminal-emulator, has mate-terminal = mate-terminal -x "$@"
    mime ^ranger/x-terminal-emulator, has xfce4-terminal = xfce4-terminal -x "$@"
    mime ^ranger/x-terminal-emulator, has konsole = konsole -e "$@"
    mime ^ranger/x-terminal-emulator, has gnome-terminal = gnome-terminal -- "$@"
    mime ^ranger/x-terminal-emulator, has xterm = xterm -e "$@"

    #-------------------------------------------
    # Misc
    #-------------------------------------------
    label wallpaper, number 11, mime ^image, has feh, X = feh --bg-scale "$1"
    label wallpaper, number 12, mime ^image, has feh, X = feh --bg-tile "$1"
    label wallpaper, number 13, mime ^image, has feh, X = feh --bg-center "$1"
    label wallpaper, number 14, mime ^image, has feh, X = feh --bg-fill "$1"

    #-------------------------------------------
    # Generic file openers
    #-------------------------------------------
    label open, has xdg-open = xdg-open -- "$@"
    label open, has open     = open -- "$@"

    # Define the editor for non-text files + pager as last action
                  !mime ^text, !ext xml|json|csv|tex|py|pl|rb|js|sh|php  = ask
    label editor, !mime ^text, !ext xml|json|csv|tex|py|pl|rb|js|sh|php  = ${editor} "$@"
    label pager,  !mime ^text, !ext xml|json|csv|tex|py|pl|rb|js|sh|php  = ${pager} "$@"


    ######################################################################
    # The actions below are left so low down in this file on purpose, so #
    # they are never triggered accidentally.                             #
    ######################################################################

    # Execute a file as program/script.
    mime application/x-executable = "$1"

    # Move the file to trash using trash-cli.
    label trash, has trash-put = trash-put -- "$@"
    label trash = mkdir -p -- ''${XDG_DATA_DIR:-$HOME/.ranger}/ranger-trash; mv -- "$@" ''${XDG_DATA_DIR:-$HOME/.ranger}/ranger-trash
  '';
  home.file."${settings.configDir}/ranger/rc.conf".text = ''

    # ===================================================================
    # This file contains the default startup commands for ranger.
    # To change them, it is recommended to create either /etc/ranger/rc.conf
    # (system-wide) or ~/.config/ranger/rc.conf (per user) and add your custom
    # commands there.
    #
    # If you copy this whole file there, you may want to set the environment
    # variable RANGER_LOAD_DEFAULT_RC to FALSE to avoid loading it twice.
    #
    # The purpose of this file is mainly to define keybindings and settings.
    # For running more complex python code, please create a plugin in "plugins/" or
    # a command in "commands.py".
    #
    # Each line is a command that will be run before the user interface
    # is initialized.  As a result, you can not use commands which rely
    # on the UI such as :delete or :mark.
    # ===================================================================

    # ===================================================================
    # == Options
    # ===================================================================

    # Which viewmode should be used?  Possible values are:
    #     miller: Use miller columns which show multiple levels of the hierarchy
    #     multipane: Midnight-commander like multipane view showing all tabs next
    #                to each other
    set viewmode miller
    #set viewmode multipane

    # How many columns are there, and what are their relative widths?
    set column_ratios 1,3,4

    # Which files should be hidden? (regular expression)
    set hidden_filter ^\.|\.(?:pyc|pyo|bak|swp)$|^lost\+found$|^__(py)?cache__$

    # Show hidden files? You can toggle this by typing 'zh'
    set show_hidden false

    # Ask for a confirmation when running the "delete" command?
    # Valid values are "always", "never", "multiple" (default)
    # With "multiple", ranger will ask only if you delete multiple files at once.
    set confirm_on_delete multiple

    # Use non-default path for file preview script?
    # ranger ships with scope.sh, a script that calls external programs (see
    # README.md for dependencies) to preview images, archives, etc.
    #set preview_script ~/.config/ranger/scope.sh

    # Use the external preview script or display simple plain text or image previews?
    set use_preview_script true

    # Automatically count files in the directory, even before entering them?
    set automatically_count_files true

    # Open all images in this directory when running certain image viewers
    # like feh or sxiv?  You can still open selected files by marking them.
    set open_all_images true

    # Be aware of version control systems and display information.
    set vcs_aware false

    # State of the four backends git, hg, bzr, svn. The possible states are
    # disabled, local (only show local info), enabled (show local and remote
    # information).
    set vcs_backend_git enabled
    set vcs_backend_hg disabled
    set vcs_backend_bzr disabled
    set vcs_backend_svn disabled

    # Truncate the long commit messages to this length when shown in the statusbar.
    set vcs_msg_length 50

    # Use one of the supported image preview protocols
    set preview_images true

    # Set the preview image method. Supported methods:
    #
    # * w3m (default):
    #   Preview images in full color with the external command "w3mimgpreview"?
    #   This requires the console web browser "w3m" and a supported terminal.
    #   It has been successfully tested with "xterm" and "urxvt" without tmux.
    #
    # * iterm2:
    #   Preview images in full color using iTerm2 image previews
    #   (http://iterm2.com/images.html). This requires using iTerm2 compiled
    #   with image preview support.
    #
    #   This feature relies on the dimensions of the terminal's font.  By default, a
    #   width of 8 and height of 11 are used.  To use other values, set the options
    #   iterm2_font_width and iterm2_font_height to the desired values.
    #
    # * terminology:
    #   Previews images in full color in the terminology terminal emulator.
    #   Supports a wide variety of formats, even vector graphics like svg.
    #
    # * urxvt:
    #   Preview images in full color using urxvt image backgrounds. This
    #   requires using urxvt compiled with pixbuf support.
    #
    # * urxvt-full:
    #   The same as urxvt but utilizing not only the preview pane but the
    #   whole terminal window.
    #
    # * kitty:
    #   Preview images in full color using kitty image protocol.
    #   Requires python PIL or pillow library.
    #   If ranger does not share the local filesystem with kitty
    #   the transfer method is changed to encode the whole image;
    #   while slower, this allows remote previews,
    #   for example during an ssh session.
    #   Tmux is unsupported.
    #
    # * ueberzug:
    #   Preview images in full color with the external command "ueberzug".
    #   Images are shown by using a child window.
    #   Only for users who run X11 in GNU/Linux.
    set preview_images_method kitty

    # Delay in seconds before displaying an image with the w3m method.
    # Increase it in case of experiencing display corruption.
    set w3m_delay 0.02

    # Manually adjust the w3mimg offset when using a terminal which needs this
    set w3m_offset 0

    # Default iTerm2 font size (see: preview_images_method: iterm2)
    set iterm2_font_width 8
    set iterm2_font_height 11

    # Use a unicode "..." character to mark cut-off filenames?
    set unicode_ellipsis false

    # BIDI support - try to properly display file names in RTL languages (Hebrew, Arabic).
    # Requires the python-bidi pip package
    set bidi_support false

    # Show dotfiles in the bookmark preview box?
    set show_hidden_bookmarks true

    # Which colorscheme to use?  These colorschemes are available by default:
    # default, jungle, snow, solarized
    set colorscheme default

    # Preview files on the rightmost column?
    # And collapse (shrink) the last column if there is nothing to preview?
    set preview_files true
    set preview_directories true
    set collapse_preview true

    # Wrap long lines in plain text previews?
    set wrap_plaintext_previews false

    # Save the console history on exit?
    set save_console_history true

    # Draw the status bar on top of the browser window (default: bottom)
    set status_bar_on_top false

    # Draw a progress bar in the status bar which displays the average state of all
    # currently running tasks which support progress bars?
    set draw_progress_bar_in_status_bar true

    # Draw borders around columns? (separators, outline, both, or none)
    # Separators are vertical lines between columns.
    # Outline draws a box around all the columns.
    # Both combines the two.
    set draw_borders none

    # Display the directory name in tabs?
    set dirname_in_tabs false

    # Enable the mouse support?
    set mouse_enabled true

    # Display the file size in the main column or status bar?
    set display_size_in_main_column true
    set display_size_in_status_bar true

    # Display the free disk space in the status bar?
    set display_free_space_in_status_bar true

    # Display files tags in all columns or only in main column?
    set display_tags_in_all_columns true

    # Set a title for the window? Updates both `WM_NAME` and `WM_ICON_NAME`
    set update_title false

    # Set the tmux/screen window-name to "ranger"?
    set update_tmux_title true

    # Shorten the title if it gets long?  The number defines how many
    # directories are displayed at once, 0 turns off this feature.
    set shorten_title 3

    # Show hostname in titlebar?
    set hostname_in_titlebar true

    # Abbreviate $HOME with ~ in the titlebar (first line) of ranger?
    set tilde_in_titlebar false

    # How many directory-changes or console-commands should be kept in history?
    set max_history_size 20
    set max_console_history_size 50

    # Try to keep so much space between the top/bottom border when scrolling:
    set scroll_offset 8

    # Flush the input after each key hit?  (Noticeable when ranger lags)
    set flushinput true

    # Padding on the right when there's no preview?
    # This allows you to click into the space to run the file.
    set padding_right true

    # Save bookmarks (used with mX and `X) instantly?
    # This helps to synchronize bookmarks between multiple ranger
    # instances but leads to *slight* performance loss.
    # When false, bookmarks are saved when ranger is exited.
    set autosave_bookmarks true

    # Save the "`" bookmark to disk.  This can be used to switch to the last
    # directory by typing "``".
    set save_backtick_bookmark true

    # You can display the "real" cumulative size of directories by using the
    # command :get_cumulative_size or typing "dc".  The size is expensive to
    # calculate and will not be updated automatically.  You can choose
    # to update it automatically though by turning on this option:
    set autoupdate_cumulative_size false

    # Turning this on makes sense for screen readers:
    set show_cursor false

    # One of: size, natural, basename, atime, ctime, mtime, type, random
    set sort natural

    # Additional sorting options
    set sort_reverse false
    set sort_case_insensitive true
    set sort_directories_first true
    set sort_unicode false

    # Enable this if key combinations with the Alt Key don't work for you.
    # (Especially on xterm)
    set xterm_alt_key false

    # Whether to include bookmarks in cd command
    set cd_bookmarks true

    # Changes case sensitivity for the cd command tab completion
    set cd_tab_case sensitive

    # Use fuzzy tab completion with the "cd" command. For example,
    # ":cd /u/lo/b<tab>" expands to ":cd /usr/local/bin".
    set cd_tab_fuzzy false

    # Avoid previewing files larger than this size, in bytes.  Use a value of 0 to
    # disable this feature.
    set preview_max_size 0

    # The key hint lists up to this size have their sublists expanded.
    # Otherwise the submaps are replaced with "...".
    set hint_collapse_threshold 10

    # Add the highlighted file to the path in the titlebar
    set show_selection_in_titlebar true

    # The delay that ranger idly waits for user input, in milliseconds, with a
    # resolution of 100ms.  Lower delay reduces lag between directory updates but
    # increases CPU load.
    set idle_delay 2000

    # When the metadata manager module looks for metadata, should it only look for
    # a ".metadata.json" file in the current directory, or do a deep search and
    # check all directories above the current one as well?
    set metadata_deep_search false

    # Clear all existing filters when leaving a directory
    set clear_filters_on_dir_change false

    # Disable displaying line numbers in main column.
    # Possible values: false, absolute, relative.
    set line_numbers false

    # When line_numbers=relative show the absolute line number in the
    # current line.
    set relative_current_zero false

    # Start line numbers from 1 instead of 0
    set one_indexed false

    # Save tabs on exit
    set save_tabs_on_exit false

    # Enable scroll wrapping - moving down while on the last item will wrap around to
    # the top and vice versa.
    set wrap_scroll false

    # Set the global_inode_type_filter to nothing.  Possible options: d, f and l for
    # directories, files and symlinks respectively.
    set global_inode_type_filter

    # This setting allows to freeze the list of files to save I/O bandwidth.  It
    # should be 'false' during start-up, but you can toggle it by pressing F.
    set freeze_files false

    # Print file sizes in bytes instead of the default human-readable format.
    set size_in_bytes false

    # Warn at startup if RANGER_LEVEL env var is greater than 0, in other words
    # give a warning when you nest ranger in a subshell started by ranger.
    # Special value "error" makes the warning more visible.
    set nested_ranger_warning true

    # ===================================================================
    # == Local Options
    # ===================================================================
    # You can set local options that only affect a single directory.

    # Examples:
    # setlocal path=~/downloads sort mtime

    # ===================================================================
    # == Command Aliases in the Console
    # ===================================================================

    alias e     edit
    alias q     quit
    alias q!    quit!
    alias qa    quitall
    alias qa!   quitall!
    alias qall  quitall
    alias qall! quitall!
    alias setl  setlocal

    alias filter     scout -prts
    alias find       scout -aets
    alias mark       scout -mr
    alias unmark     scout -Mr
    alias search     scout -rs
    alias search_inc scout -rts
    alias travel     scout -aefklst

    # ===================================================================
    # == Define keys for the browser
    # ===================================================================

    # Basic
    map     Q quitall
    map     q quit
    copymap q ZZ ZQ

    map R     reload_cwd
    map F     set freeze_files!
    map <C-r> reset
    map <C-l> redraw_window
    map <C-c> abort
    map <esc> change_mode normal
    map ~ set viewmode!

    map i display_file
    map <A-j> scroll_preview 1
    map <A-k> scroll_preview -1
    map ? help
    map W display_log
    map w taskview_open
    map S shell $SHELL

    map :  console
    map ;  console
    map !  console shell%space
    map @  console -p6 shell  %%s
    map #  console shell -p%space
    map s  console shell%space
    map r  chain draw_possible_programs; console open_with%space
    map f  console find%space
    map cd console cd%space

    map <C-p> chain console; eval fm.ui.console.history_move(-1)

    # Change the line mode
    map Mf linemode filename
    map Mi linemode fileinfo
    map Mm linemode mtime
    map Mh linemode humanreadablemtime
    map Mp linemode permissions
    map Ms linemode sizemtime
    map MH linemode sizehumanreadablemtime
    map Mt linemode metatitle

    # Tagging / Marking
    map t       tag_toggle
    map ut      tag_remove
    map "<any>  tag_toggle tag=%any
    map <Space> mark_files toggle=True
    map v       mark_files all=True toggle=True
    map uv      mark_files all=True val=False
    map V       toggle_visual_mode
    map uV      toggle_visual_mode reverse=True

    # For the nostalgics: Midnight Commander bindings
    map <F1> help
    map <F2> rename_append
    map <F3> display_file
    map <F4> edit
    map <F5> copy
    map <F6> cut
    map <F7> console mkdir%space
    map <F8> console delete
    #map <F8> console trash
    map <F10> exit

    # In case you work on a keyboard with dvorak layout
    map <UP>       move up=1
    map <DOWN>     move down=1
    map <LEFT>     move left=1
    map <RIGHT>    move right=1
    map <HOME>     move to=0
    map <END>      move to=-1
    map <PAGEDOWN> move down=1   pages=True
    map <PAGEUP>   move up=1     pages=True
    map <CR>       move right=1
    #map <DELETE>   console delete
    map <INSERT>   console touch%space

    # VIM-like
    copymap <UP>       k
    copymap <DOWN>     j
    copymap <LEFT>     h
    copymap <RIGHT>    l
    copymap <HOME>     gg
    copymap <END>      G
    copymap <PAGEDOWN> <C-F>
    copymap <PAGEUP>   <C-B>

    map J  move down=0.5  pages=True
    map K  move up=0.5    pages=True
    copymap J <C-D>
    copymap K <C-U>

    # Jumping around
    map H     history_go -1
    map L     history_go 1
    map ]     move_parent 1
    map [     move_parent -1
    map }     traverse
    map {     traverse_backwards
    map )     jump_non

    map gh cd ~
    map ge cd /etc
    map gu cd /usr
    map gd cd /dev
    map gl cd -r .
    map gL cd -r %f
    map go cd /opt
    map gv cd /var
    map gm cd /media
    map gi eval fm.cd('/run/media/' + os.getenv('USER'))
    map gM cd /mnt
    map gs cd /srv
    map gp cd /tmp
    map gr cd /
    map gR eval fm.cd(ranger.RANGERDIR)
    map g/ cd /
    map g? cd /usr/share/doc/ranger

    # External Programs
    map E  edit
    map du shell -p du --max-depth=1 -h --apparent-size
    map dU shell -p du --max-depth=1 -h --apparent-size | sort -rh
    map yp yank path
    map yd yank dir
    map yn yank name
    map y. yank name_without_extension

    # Filesystem Operations
    map =  chmod

    map cw console rename%space
    map a  rename_append
    map A  eval fm.open_console('rename ' + fm.thisfile.relative_path.replace("%", "%%"))
    map I  eval fm.open_console('rename ' + fm.thisfile.relative_path.replace("%", "%%"), position=7)

    map pp paste
    map po paste overwrite=True
    map pP paste append=True
    map pO paste overwrite=True append=True
    map pl paste_symlink relative=False
    map pL paste_symlink relative=True
    map phl paste_hardlink
    map pht paste_hardlinked_subtree
    map pd console paste dest=
    map p`<any> paste dest=%any_path
    map p'<any> paste dest=%any_path

    map dD console delete
    map dT console trash

    map dd cut
    map ud uncut
    map da cut mode=add
    map dr cut mode=remove
    map dt cut mode=toggle

    map yy copy
    map uy uncut
    map ya copy mode=add
    map yr copy mode=remove
    map yt copy mode=toggle

    # Temporary workarounds
    map dgg eval fm.cut(dirarg=dict(to=0), narg=quantifier)
    map dG  eval fm.cut(dirarg=dict(to=-1), narg=quantifier)
    map dj  eval fm.cut(dirarg=dict(down=1), narg=quantifier)
    map dk  eval fm.cut(dirarg=dict(up=1), narg=quantifier)
    map ygg eval fm.copy(dirarg=dict(to=0), narg=quantifier)
    map yG  eval fm.copy(dirarg=dict(to=-1), narg=quantifier)
    map yj  eval fm.copy(dirarg=dict(down=1), narg=quantifier)
    map yk  eval fm.copy(dirarg=dict(up=1), narg=quantifier)

    # Searching
    map /  console search%space
    map n  search_next
    map N  search_next forward=False
    map ct search_next order=tag
    map cs search_next order=size
    map ci search_next order=mimetype
    map cc search_next order=ctime
    map cm search_next order=mtime
    map ca search_next order=atime

    # Tabs
    map <C-n>     tab_new
    map <C-w>     tab_close
    map <TAB>     tab_move 1
    map <S-TAB>   tab_move -1
    map <A-Right> tab_move 1
    map <A-Left>  tab_move -1
    map gt        tab_move 1
    map gT        tab_move -1
    map gn        tab_new
    map gc        tab_close
    map uq        tab_restore
    map <a-1>     tab_open 1
    map <a-2>     tab_open 2
    map <a-3>     tab_open 3
    map <a-4>     tab_open 4
    map <a-5>     tab_open 5
    map <a-6>     tab_open 6
    map <a-7>     tab_open 7
    map <a-8>     tab_open 8
    map <a-9>     tab_open 9
    map <a-r>     tab_shift 1
    map <a-l>     tab_shift -1

    # Sorting
    map or set sort_reverse!
    map oz set sort=random
    map os chain set sort=size;      set sort_reverse=False
    map ob chain set sort=basename;  set sort_reverse=False
    map on chain set sort=natural;   set sort_reverse=False
    map om chain set sort=mtime;     set sort_reverse=False
    map oc chain set sort=ctime;     set sort_reverse=False
    map oa chain set sort=atime;     set sort_reverse=False
    map ot chain set sort=type;      set sort_reverse=False
    map oe chain set sort=extension; set sort_reverse=False

    map oS chain set sort=size;      set sort_reverse=True
    map oB chain set sort=basename;  set sort_reverse=True
    map oN chain set sort=natural;   set sort_reverse=True
    map oM chain set sort=mtime;     set sort_reverse=True
    map oC chain set sort=ctime;     set sort_reverse=True
    map oA chain set sort=atime;     set sort_reverse=True
    map oT chain set sort=type;      set sort_reverse=True
    map oE chain set sort=extension; set sort_reverse=True

    map dc get_cumulative_size

    # Settings
    map zc    set collapse_preview!
    map zd    set sort_directories_first!
    map zh    set show_hidden!
    map <C-h> set show_hidden!
    copymap <C-h> <backspace>
    copymap <backspace> <backspace2>
    map zI    set flushinput!
    map zi    set preview_images!
    map zm    set mouse_enabled!
    map zp    set preview_files!
    map zP    set preview_directories!
    map zs    set sort_case_insensitive!
    map zu    set autoupdate_cumulative_size!
    map zv    set use_preview_script!
    map zf    console filter%space
    copymap zf zz

    # Filter stack
    map .d filter_stack add type d
    map .f filter_stack add type f
    map .l filter_stack add type l
    map .m console filter_stack add mime%space
    map .n console filter_stack add name%space
    map .# console filter_stack add hash%space
    map ." filter_stack add duplicate
    map .' filter_stack add unique
    map .| filter_stack add or
    map .& filter_stack add and
    map .! filter_stack add not
    map .r filter_stack rotate
    map .c filter_stack clear
    map .* filter_stack decompose
    map .p filter_stack pop
    map .. filter_stack show

    # Bookmarks
    map `<any>  enter_bookmark %any
    map '<any>  enter_bookmark %any
    map m<any>  set_bookmark %any
    map um<any> unset_bookmark %any

    map m<bg>   draw_bookmarks
    copymap m<bg>  um<bg> `<bg> '<bg>

    # Generate all the chmod bindings with some python help:
    eval for arg in "rwxXst": cmd("map +u{0} shell -f chmod u+{0} %s".format(arg))
    eval for arg in "rwxXst": cmd("map +g{0} shell -f chmod g+{0} %s".format(arg))
    eval for arg in "rwxXst": cmd("map +o{0} shell -f chmod o+{0} %s".format(arg))
    eval for arg in "rwxXst": cmd("map +a{0} shell -f chmod a+{0} %s".format(arg))
    eval for arg in "rwxXst": cmd("map +{0}  shell -f chmod u+{0} %s".format(arg))

    eval for arg in "rwxXst": cmd("map -u{0} shell -f chmod u-{0} %s".format(arg))
    eval for arg in "rwxXst": cmd("map -g{0} shell -f chmod g-{0} %s".format(arg))
    eval for arg in "rwxXst": cmd("map -o{0} shell -f chmod o-{0} %s".format(arg))
    eval for arg in "rwxXst": cmd("map -a{0} shell -f chmod a-{0} %s".format(arg))
    eval for arg in "rwxXst": cmd("map -{0}  shell -f chmod u-{0} %s".format(arg))

    # ===================================================================
    # == Define keys for the console
    # ===================================================================
    # Note: Unmapped keys are passed directly to the console.

    # Basic
    cmap <tab>   eval fm.ui.console.tab()
    cmap <s-tab> eval fm.ui.console.tab(-1)
    cmap <ESC>   eval fm.ui.console.close()
    cmap <CR>    eval fm.ui.console.execute()
    cmap <C-l>   redraw_window

    copycmap <ESC> <C-c>
    copycmap <CR>  <C-j>

    # Move around
    cmap <up>    eval fm.ui.console.history_move(-1)
    cmap <down>  eval fm.ui.console.history_move(1)
    cmap <left>  eval fm.ui.console.move(left=1)
    cmap <right> eval fm.ui.console.move(right=1)
    cmap <home>  eval fm.ui.console.move(right=0, absolute=True)
    cmap <end>   eval fm.ui.console.move(right=-1, absolute=True)
    cmap <a-b> eval fm.ui.console.move_word(left=1)
    cmap <a-f> eval fm.ui.console.move_word(right=1)

    copycmap <a-b> <a-left>
    copycmap <a-f> <a-right>

    # Line Editing
    cmap <backspace>  eval fm.ui.console.delete(-1)
    cmap <delete>     eval fm.ui.console.delete(0)
    cmap <C-w>        eval fm.ui.console.delete_word()
    cmap <A-d>        eval fm.ui.console.delete_word(backward=False)
    cmap <C-k>        eval fm.ui.console.delete_rest(1)
    cmap <C-u>        eval fm.ui.console.delete_rest(-1)
    cmap <C-y>        eval fm.ui.console.paste()

    # And of course the emacs way
    copycmap <ESC>       <C-g>
    copycmap <up>        <C-p>
    copycmap <down>      <C-n>
    copycmap <left>      <C-b>
    copycmap <right>     <C-f>
    copycmap <home>      <C-a>
    copycmap <end>       <C-e>
    copycmap <delete>    <C-d>
    copycmap <backspace> <C-h>

    # Note: There are multiple ways to express backspaces.  <backspace> (code 263)
    # and <backspace2> (code 127).  To be sure, use both.
    copycmap <backspace> <backspace2>

    # This special expression allows typing in numerals:
    cmap <allow_quantifiers> false

    # ===================================================================
    # == Pager Keybindings
    # ===================================================================

    # Movement
    pmap  <down>      pager_move  down=1
    pmap  <up>        pager_move  up=1
    pmap  <left>      pager_move  left=4
    pmap  <right>     pager_move  right=4
    pmap  <home>      pager_move  to=0
    pmap  <end>       pager_move  to=-1
    pmap  <pagedown>  pager_move  down=1.0  pages=True
    pmap  <pageup>    pager_move  up=1.0    pages=True
    pmap  <C-d>       pager_move  down=0.5  pages=True
    pmap  <C-u>       pager_move  up=0.5    pages=True

    copypmap <UP>       k  <C-p>
    copypmap <DOWN>     j  <C-n> <CR>
    copypmap <LEFT>     h
    copypmap <RIGHT>    l
    copypmap <HOME>     g
    copypmap <END>      G
    copypmap <C-d>      d
    copypmap <C-u>      u
    copypmap <PAGEDOWN> n  f  <C-F>  <Space>
    copypmap <PAGEUP>   p  b  <C-B>

    # Basic
    pmap     <C-l> redraw_window
    pmap     <ESC> pager_close
    copypmap <ESC> q Q i <F3>
    pmap E      edit_file

    # ===================================================================
    # == Taskview Keybindings
    # ===================================================================

    # Movement
    tmap <up>        taskview_move up=1
    tmap <down>      taskview_move down=1
    tmap <home>      taskview_move to=0
    tmap <end>       taskview_move to=-1
    tmap <pagedown>  taskview_move down=1.0  pages=True
    tmap <pageup>    taskview_move up=1.0    pages=True
    tmap <C-d>       taskview_move down=0.5  pages=True
    tmap <C-u>       taskview_move up=0.5    pages=True

    copytmap <UP>       k  <C-p>
    copytmap <DOWN>     j  <C-n> <CR>
    copytmap <HOME>     g
    copytmap <END>      G
    copytmap <C-u>      u
    copytmap <PAGEDOWN> n  f  <C-F>  <Space>
    copytmap <PAGEUP>   p  b  <C-B>

    # Changing priority and deleting tasks
    tmap J          eval -q fm.ui.taskview.task_move(-1)
    tmap K          eval -q fm.ui.taskview.task_move(0)
    tmap dd         eval -q fm.ui.taskview.task_remove()
    tmap <pagedown> eval -q fm.ui.taskview.task_move(-1)
    tmap <pageup>   eval -q fm.ui.taskview.task_move(0)
    tmap <delete>   eval -q fm.ui.taskview.task_remove()

    # Basic
    tmap <C-l> redraw_window
    tmap <ESC> taskview_close
    copytmap <ESC> q Q w <C-c>


  '';
}
