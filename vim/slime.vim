" Use tmux as slime target
let g:slime_target = "tmux"

" Hardcode target pane to %0 (change if your psql pane is different)
let g:slime_default_config = {"socket_name": "default", "target_pane": "%0"}

" Also set buffer-local slime config for current buffer
autocmd BufEnter * let b:slime_config = g:slime_default_config

" Avoid prompt asking for slime target every time
let g:slime_dont_ask_default = 1

" Map <leader>r to send current file to psql pane %0
nnoremap <leader>r :execute 'SlimeSend1' '\i ' . expand('%:p')<CR>
" Automatically send current file to psql pane %0 on save
autocmd BufWritePost * if &filetype ==# 'sql' | execute 'SlimeSend1' '\i ' . expand('%:p') | endif