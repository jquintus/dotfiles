" Set config file path

let g:config_file = '~/dotfiles/vim/mac.vim'
let g:config_vim_backup= $HOME."/.vim_backup"
let g:config_vim_undo= $HOME."/.vim_undo"
let g:config_vim_notes= $HOME."/OneDrive/bin/config/vimfiles"

execute 'source' g:config_file
