#!/bin/bash -e

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

# qnamebuf, search for file by name
# README: http://www.vim.org/scripts/script.php?script_id=3217
mkdir ~/.vim
pushd ~/.vim
wget -O qnamebuf.zip http://www.vim.org/scripts/download_script.php?src_id=15680
unzip ./qnamebuf.zip
popd

# Install: vimscreen
# README: http://www.vim.org/scripts/script.php?script_id=2711
wget -O screen.vba http://www.vim.org/scripts/download_script.php?src_id=16100
vim -c 'so %' -c 'q' screen.vba

## Download, compile and install tmux 1.6
#sudo apt-get install libevent-dev
#wget https://launchpad.net/ubuntu/+archive/primary/+files/tmux_1.6.orig.tar.gz
#tar xzfv tmux_1.6.orig.tar.gz
#cd tmux-1.6/
#./configure
#make
#sudo make install
## Then move tmux over to /usr/local/bin

## Install R
## README: http://cran.r-project.org/bin/linux/ubuntu/README
# echo "deb http://cran.cnr.Berkeley.edu/bin/linux/ubuntu lucid/" >> /etc/apt/sources.list
# sudo apt-get update
# sudo apt-get install r-base

## Install: ML for hackers packages
## Repository: https://github.com/johnmyleswhite/ML_for_Hackers.git
## In R: source("package_installer.R")
wget https://raw.github.com/johnmyleswhite/ML_for_Hackers/master/package_installer.R

# Install: colorout plugin for R

# README: http://www.lepem.ufc.br/jaa/colorout.html
# In R:
#   download.file("http://www.lepem.ufc.br/jaa/colorout_1.0-0.tar.gz", destfile = "colorout_1.0-0.tar.gz")
#   install.packages("colorout_1.0-0.tar.gz")

# Install: vimcom for R (for letting R talk to vim)
# README: http://www.lepem.ufc.br/jaa/vimcom.html
# In R:
#  download.file("http://www.lepem.ufc.br/jaa/vimcom_0.9-3.tar.gz", destfile = "vimcom_0.9-3.tar.gz")
#  install.packages("vimcom_0.9-3.tar.gz")
# vim-r
# README: http://www.lepem.ufc.br/jaa/r-plugin.html#r-plugin-files

