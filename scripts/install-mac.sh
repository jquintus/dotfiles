#!/bin/bash

# Install NeoVim

mkdir -p ~/.config/nvim
rm ~/.config/nvim/init.lua
ln -nfs ~/dotfiles/neo-vim/int.lua  ~/.config/nvim/init.lua
