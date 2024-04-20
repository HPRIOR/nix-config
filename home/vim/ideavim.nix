{settings, ...}: {
  home.file."${settings.homeDir}/.ideavimrc".text = ''
    """ Map leader to space ---------------------
    let mapleader=" "

    """ Plugins  --------------------------------
    set surround
    set multiple-cursors
    set commentary
    set argtextobj
    set textobj-entire
    set ReplaceWithRegister

    " settings
    set ideajoin
    set ideamarks
    set incsearch
    set hlsearch
    set clipboard+=unnamed


    """ Mappings --------------------------------
    " movement
    nmap <C-o>    <Action>(Back)
    nmap <C-i>    <Action>(Forward)
    map  gi           <Action>(GotoImplementation)
    nmap gu           <Action>(ShowUsages)
    map  gU           <Action>(FindUsages)
    map  gd           <Action>(GotoDeclaration)

    " editing
    map <leader>cs    <Action>(ChangeSignature)
    map <leader>a     <Action>(QuickActions)
    map gf            <Action>(ReformatCode)
    map <leader>cc    <Action>(CodeCleanup)
    map <leader>r     <Action>(RenameElement)
    map <leader>/     <Action>(Find)
    map <leader>sr    <Action>(Replace)
    map <leader>vm    <Action>(Git.CompareWithBranch)
    map <leader>vh    <Action>(LocalHistory.ShowHistory)
    map gcc           <Action>(CommentByLineComment)
    map gco           <Action>(CommentByBlockComment)
    vmap <C-p> y'>p

    " diagnostics
    map <leader>d     <Action>(ShowErrorDescription)
    map ge            <Action>(GotoNextError)
    map gp            <Action>(GotoPreviousError)
    map <leader>xx    <Action>(ActivateProblemsViewToolWindow)

    " window management
    map <leader>q     <Action>(CloseActiveTab)
    map <leader>1     <Action>(GoToTab1)
    map <leader>2     <Action>(GoToTab2)
    map <leader>3     <Action>(GoToTab3)
    map <leader>4     <Action>(GoToTab4)
    map <leader>5     <Action>(GoToTab5)
    map <leader>6     <Action>(GoToTab6)
    map <leader>7     <Action>(GoToTab7)
    map <leader>8     <Action>(GoToTab8)
    map <leader>9     <Action>(GoToTab9)

    " Split Movement
    nmap <leader>h <c-w>h
    nmap <leader>l <c-w>l
    nmap <leader>k <c-w>k
    nmap <leader>j <c-w>j

    " Splits manipulation
    nmap <leader>sh :action SplitHorizontally<cr>
    nmap <leader>sv :action SplitVertically<cr>
    nmap <leader>sc :action Unsplit<cr>
    nmap <leader>sC :action UnsplitAll<cr>
    nmap <leader>sd :action OpenEditorInOppositeTabGroup<cr>

    "Tab
    nmap <leader>w :action CloseContent<cr>
    nmap <leader>W :action ReopenClosedTab<cr>
    map <leader>]     <Action>(NextTab)
    map <leader>[     <Action>(PreviousTab)
    map <leader>q     <Action>(CloseActiveTab)
  '';
}
