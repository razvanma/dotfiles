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
# Ctrl+a, k to kill
sudo screen /dev/ttyACM0 9600

# Install the RCSwitch library from github.
# 1. Download zip from https://github.com/sui77/rc-switch 
# 2. Run 'arduino' and go to Sketch=>Include Library=>Add Zip Library
# 3. Use this command to see where it's installed:
arduino-cli lib examples rc-switch-2.6.4

# Compile the sketch and su upload
arduino-cli compile -b arduino:avr:uno
sudo arduino-cli upload -p /dev/ttyACM0 --fqbn arduino:avr:uno

# Record and decode at 315Mhz
rtl_433 -f 315M -S unknown
rtl_433 -A *.cu8

# Go to triq.org to view .cu8 files

# Script to scan and viz a broad range of frequencies
# http://kmkeen.com/tmp/heatmap.py.txt
rtl_power -f 118M:137M:10k -e 5m -i 1s survey.csv
python heatmap.py survey.csv survey.png

# For tuning and scanning.  sdrangel has many pluggins.
sdrangel
gqrx
