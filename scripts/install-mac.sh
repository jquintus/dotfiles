#!/bin/bash

########################################
echo Install NeoVim Configs
########################################
mkdir -p ~/.config/nvim
rm ~/.config/nvim/init.lua
ln -nfs ~/dotfiles/neo-vim/int.lua  ~/.config/nvim/init.lua

########################################
echo Install gVim configs
########################################
[ -f ~/.vimrc ] && rm ~/.vimrc
ln -nfs ~/dotfiles/vim/init.vim ~/.vimrc

########################################
echo Install tmux configs
########################################
[ -f ~/.tmux.conf ] && rm ~/.tmux.conf
ln -nfs ~/dotfiles/tmux/_tmux.conf ~/.tmux.conf

########################################
echo Install shell configs
########################################
[ -f ~/.zshrc ] && rm ~/.zshrc
ln -nfs ~/dotfiles/zsh/_zshrc ~/.zshrc

[ -f ~/.aliases ] && rm ~/.aliases 
ln -nfs ~/dotfiles/_aliases ~/.aliases 

########################################
echo Install git configs
########################################
[ -f ~/.gitconfig ] && rm ~/.gitconfig
ln -nfs ~/dotfiles/git/_gitconfig ~/.gitconfig

echo Done.