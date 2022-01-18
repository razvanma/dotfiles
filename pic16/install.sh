# Download the compiler
sudo pacman -S sdcc

# Enable /uncomment Multilib, go to /etc/pacman.conf

# Update system and show 32-bit packages
sudo pacman -Syyu
pacman -Sl | grep lib32

# Install required libraries, including XC8 compiler
yay -S lib32-fakeroot
yay -S microchip-mplabx-bin
yay -S microchip-mplabxc8-bin

# Run full mplab IDE, press alt=>v=>f to get screen to redraw
mplab_ide

# Run IPE
mplab_ipe

# Upload program from commandline
java -jar /opt/microchip/mplabx/v5.50/mplab_platform/mplab_ipe/ipecmd.jar
