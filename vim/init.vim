" Set config file path
let g:config_file = '~/dotfiles/vim/mac.vim'

execute 'source' g:config_file
nnoremap <F3> :execute 'source' g:config_file<CR>
nnoremap <S-F3> :execute 'edit' g:config_file<CR>