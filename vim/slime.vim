"*******************************************************************************
" Slime Configuration
" This is untested at this point.
" Source: https://chatgpt.com/share/6898b4f0-9174-800e-97b4-c978ac6e006b
"*******************************************************************************
" This will allow you to send code to a tmux pane.
"
" To use, open a tmux pane and run `:SlimeSend1 <command>`
" For example, to send the current file to psql, run `:SlimeSend1 \i %`
" To send a command to the current pane, run `:SlimeSend1 <command>`
"*******************************************************************************

" Use tmux as target
let g:slime_target = "tmux"

" Auto-detect left pane from current Vim pane
function! SlimeTmuxLeftPane()
  let l:current_pane = system("tmux display-message -p '#{pane_id}'")[:-2]
  let l:left_pane = system("tmux list-panes -F '#{pane_id} #{pane_left}' | awk '$2==1 {print $1}'")[:-2]
  if empty(l:left_pane)
    echoerr "No left pane found"
    return
  endif
  let g:slime_default_config = {"socket_name": "default", "target_pane": l:left_pane}
endfunction

" Run auto-detect on Vim start
autocmd VimEnter * call SlimeTmuxLeftPane()

" Don't prompt every time
let g:slime_dont_ask_default = 1

" Map <leader>r to send current file to psql
nnoremap <leader>r :SlimeSend1 \i %<CR>
