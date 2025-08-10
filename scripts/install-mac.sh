#!/bin/bash

echo Install NeoVim Configs
mkdir -p ~/.config/nvim
rm ~/.config/nvim/init.lua
ln -nfs ~/dotfiles/neo-vim/int.lua  ~/.config/nvim/init.lua

echo Install gVim configs
[ -f ~/.vimrc ] && rm ~/.vimrc
ln -nfs ~/dotfiles/vim/init.vim ~/.vimrc
