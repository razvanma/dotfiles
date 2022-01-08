# Network management
pacman -Sy netctl 
pacman -Sy dialog dhcpd wpa_supplicant ifplugd
pacman -Sy dialog dhcpcd wpa_supplicant ifplugd

# Boot loader / GRUB
pacman -S os-prober
pacman -S grub efibootmgr

# Basics
pacman -S pacman-contrib
pacman -Sy vim
pacman -S vi-vim-symlink
pacman -S --needed base-devel git
pacman -S --needed sudo

# X-windows
pacman -S xorg
pacman -S xinit
pacman -Ss xf86-video
pacman -S xorg-xinit
# not sure: pacman -Qkk haskell-utf8-string
pacman -S xmonad xmonad-contrib
pacman -S xterm xorg-xclock

# Graphics
pacman -S nvidia
pacman -S glxinfo
pacman -S mesa mesa-demos

# Sound card install
sudo pacman -S pulseaudio
sudo pacman -S pulseaudio-alsa
sudo pacman -S pulseaudio-equalizer
sudo pacman -S pacmixer
sudo pacman -S alsa-card-profile

# Sound card --https://unix.stackexchange.com/questions/633019/arch-linux-doesnt-recognize-sound-driver-dummy-output
pacmd list-cards
pacmd set-card-profile 0 output:hdmi-stereo
sudo touch /etc/modprobe.d/audio-fix.conf  
sudo echo "blacklist snd-sof-pci" > /etc/modprobe.d/audio-fix.conf 
sudo echo "options snd-intel-dspcfg dsp_driver=1" >> /etc/modprobe.d/audio-fix.conf 

# Turn off pc speaker dings
rmmod pcspkr
# or in /etc/modprobe.d/blacklist.conf, add "blacklist pcspkr"
# in vim, :set visualbell

# Volume Control
alsamixer

# Touchpad - use 'synclient -l' to see and play with settings
sudo pacman -S xf86-input-synaptics

# Docker
sudo pacman -S docker
sudo systemctl start docker.socket
yay -S nvidia-docker-toolkit

# Docker - avoiding sudo
sudo groupadd docker
sudo usermod -aG docker $USER
newgrp docker
docker -v

# Install meld for visual git diffs
sudoe pacman -S meld

# start docker and the nvdia drivera
systemctl start docker.socket
nvidia-modprobe -u -c=0

# Test out GPU in docker
docker run --gpus all --device /dev/nvidia0 --device /dev/nvidia-uvm --device /dev/nvidia-uvm-tools --device /dev/nvidiactl nvidia/cuda:11.3.0-runtime-ubuntu20.04 nvidia-smi

# Tensorflow with GPU 
# Do NOT run as sudo, so that nvidia-docker-toolkit can be found
# restart exited container after rebooting host OS:
# https://github.com/NVIDIA/nvidia-docker/issues/288 
docker run --gpus all --device /dev/nvidia0 --device /dev/nvidia-uvm --device /dev/nvidia-uvm-tools --device /dev/nvidiactl -it tensorflow/tensorflow:latest-gpu python -c 'import tensorflow as tf; print(tf.config.list_physical_devices("GPU"))'

# Google cloud container with Jupyter and tensorflow
# from
docker run -d -p 8080:8080 -v `pwd`:/home --gpus all --device /dev/nvidia0 --device /dev/nvidia-uvm --device /dev/nvidia-uvm-tools --device /dev/nvidiactl -it gcr.io/deeplearning-platform-release/tf2-gpu.2-6

# Simple examples at https://github.com/tensorflow/examples/tree/master/courses/udacity_deep_learning 

# docker ps and docker attach are useful for jumping into the running container

# docker / tf: https://www.youtube.com/watch?v=eY7znLC9PDw#

# Update arch
sudo pacman -Syu

# install ngspice / kicad
sudo pacman -S ngspice
sudo pacman -S kicad
sudo pacman -S kicad-library

# arduino
sudo pacman -S arduino
sudo pacman -S arduino-cli
sudo pacman -S arduino-avr-core
sudo pacman -S avr-libc
yay -S arduino-mk

# arduino-cli board list
# arduino-cli core install arduino:avr
# arduino-cli compile -b arduino:avr:uno ./blink.ino
# sudo arduino-cli core install arduino:avr
# sudo arduino-cli upload -p /dev/ttyACM0 --fqbn arduino:avr:uno ./blink.ino
