# Plug it in to automatically get a /dev/ttyACM0

# Find the board name
arduino-cli board list

# Install its driver for both user and SU
arduino-cli core install arduino:avr
sudo arduino-cli core install arduino:avr

# Talk to the arduino
# sudo pacman -S busybox
sudo busybox microcom -t 9600 /dev/ttyACM0

# connect to the device to send / receive serial data
screen /dev/ttyACM0 9600

# Install the RCSwitch library from github.
# 1. Download zip from https://github.com/sui77/rc-switch 
# 2. Run 'arduino' and go to Sketch=>Include Library=>Add Zip Library

# Compile the sketch and su upload
arduino-cli compile -b arduino:avr:uno
sudo arduino-cli upload -p /dev/ttyACM0 --fqbn arduino:avr:uno

