" Use tmux as slime target
let g:slime_target = "tmux"

" Hardcode target pane to %0 (change if your psql pane is different)
let g:slime_default_config = {"socket_name": "default", "target_pane": "%0"}

" Also set buffer-local slime config for current buffer
autocmd BufEnter * let b:slime_config = g:slime_default_config

" Avoid prompt asking for slime target every time
let g:slime_dont_ask_default = 1

" Function to save and send file to psql
function! SaveAndSendToPsql()
    write
    execute 'SlimeSend1' '\i ' . expand('%:p')
endfunction

" Map <leader>r to save and send current file to psql pane %0
nnoremap <leader>r :call SaveAndSendToPsql()<cr>

" Automatically send current file to psql pane %0 on save
" I commented this out because it felt dangerous. I could save the file for any
" number of reasons, and I don't want to accidentally run a query.
" autocmd BufWritePost * if &filetype ==# 'sql' | execute 'SlimeSend1' '\i ' . expand('%:p') | endif