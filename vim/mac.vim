"*******************************************************************************
" Mac Specific Stuff
" <D-j> : this maps the "command key + j"
"*******************************************************************************
" To set colors up in ITerm
" https://tomlankhorst.nl/iterm-tmux-vim-true-color/
set termguicolors
let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"

nnoremap <D-cr> :set fu!<cr>  " Set fullscreen

" Command + Direction to move around windows
nnoremap <D-j> <c-w>j
nnoremap <D-h> <c-w>h
nnoremap <D-k> <c-w>k
nnoremap <D-l> <c-w>l
