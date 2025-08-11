"*******************************************************************************
" Vim Plugins
"*******************************************************************************
" Warning: This will cause an error to be thrown the first time you open Vim.
" The plugin manager will be downloaded but it's not loaded, so any calls to it
" will fail. 
" 
" All you have to do is restart vim. This time the plugin manager will exist so
" it can be loaded on open.
" At this point you can call `:PlugInstall`
"*******************************************************************************
" TLDR Instructions: 
" 1. Open Vim. See an error.
" 2. Close Vim.
" 3. Reopen Vim.
" 4. Call :PlugInstall
"*******************************************************************************


" Bootstrap vim-plug if it's not installed
if empty(glob('~/.vim/autoload/plug.vim'))
    silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
    finish
endif

" Load vim-plug
call plug#begin('~/.vim/plugged')

Plug 'preservim/nerdtree'
Plug 'tpope/vim-fugitive'

call plug#end()

