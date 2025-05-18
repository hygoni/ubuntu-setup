#!/bin/bash

sudo apt install -y exuberant-ctags cscope
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
cp configs/vimrc ~/.vimrc
vim +PluginInstall +qall
