#!/bin/bash -e

# files, control brigness, mouse bounds, etc:
# ~/.xinitrc
# ~/.Xresources

# pacman -S sf86-input-synaptics
# ~/usr/share/X11/xorg.conf.d/70-synaptics.conf

# Install config files
cp ./.vimrc ~/.vimrc
cp ./.tmux.conf ~/.tmux.conf

# Install tmux
# for v1.6 'tmux -V' should say 'tmux 1.6'
sudo apt-get install tmux

# Install qgit
sudo apt-get install qgit

# Install sshfs
sudo apt-get install sshfs

# 256-color terminal (https://push.cx/2008/256-color-xterms-in-ubuntu)
#
# Xterm needs a little more configuration, edit ~/.Xdefaults to add:
#
#*customization: -color
#XTerm*termName:  xterm-256color
#
#To make this apply to new terminals (so you don’t have to log out and back in), run:
#  xrdb -merge ~/.Xdefaults
#
# In screen, set:
# TERM=xterm-256color
#
sudo apt-get install aptitude
sudo aptitude install ncurses-term

# Install ack-grep package
sudo apt-get install ack-grep

# qnamebuf, search for file by name
# README: http://www.vim.org/scripts/script.php?script_id=3217
mkdir -p ~/.vim
pushd ~/.vim
wget -O qnamebuf.zip http://www.vim.org/scripts/download_script.php?src_id=15680
unzip ./qnamebuf.zip

# syntax highlighting for .Rmd R markdown files
# wget https://raw.githubusercontent.com/jcfaria/Vim-R-plugin/master/syntax/rmd.vim
popd

# Install: vimscreen
# README: http://www.vim.org/scripts/script.php?script_id=2711
wget -O screen.vba http://www.vim.org/scripts/download_script.php?src_id=16100
vim -c 'so %' -c 'q' screen.vba

# install oh my zsh
wget https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | zsh
chsh -s `which zsh`

# install vundle under ~/.vim
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim

# install vim themes
git clone https://github.com/flazz/vim-colorschemes.git temp
mkdir -p ~/.vim/colors
cp temp/colors/* ~/.vim/colors
rm -rf temp

# Trigger installer for all vim vundle packages.
vim +PluginInstall +qall
