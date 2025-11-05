"*******************************************************************************
" Vim Plugins
"*******************************************************************************
" This will install the vim-plug plugin manager if it's not already installed.
" To add plugins, add them to the Plug line below. and call `:PlugInstall`
"*******************************************************************************
" TLDR Instructions: 
" 1. Open Vim. 
" 2. Call :PlugInstall
"*******************************************************************************
" To clean up all of the plugins and start fresh:
" rm -rf ~/.vim/autoload/plug.vim ~/.vim/plugged 
"*******************************************************************************


" Bootstrap vim-plug if it's not installed
if empty(glob('~/.vim/autoload/plug.vim'))
    silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    source ~/.vim/autoload/plug.vim
    " Defer plugin loading to next VimEnter to ensure vim-plug is fully initialized
    autocmd VimEnter * source ~/dotfiles/vim/plugins.vim
    finish
endif

" Load vim-plug
call plug#begin('~/.vim/plugged')

Plug 'preservim/nerdtree'
Plug 'tpope/vim-fugitive'
Plug 'jpalardy/vim-slime'
Plug 'easymotion/vim-easymotion'
Plug 'mechatroner/rainbow_csv'

Plug 'jlanzarotta/bufexplorer'

call plug#end()
