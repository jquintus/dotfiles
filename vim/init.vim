" Set config paths. These _may_ change on different platforms
let g:config_file = '~/dotfiles/vim/settings.vim'
let g:config_vim_backup= $HOME."/.vim_backup"
let g:config_vim_undo= $HOME."/.vim_undo"
let g:config_vim_notes= $HOME."/OneDrive/bin/config/vimfiles"


" Use this syntax if you want to use variables
execute 'source' g:config_file

" Platform-specific configurations
if has('mac')
    source ~/dotfiles/vim/mac.vim
elseif has('win32') || has('win64')
    source ~/dotfiles/vim/win.vim
endif

