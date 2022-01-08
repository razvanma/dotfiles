# Plug it in to automatically get a /dev/ttyACM0

# Find the board name
arduino-cli board list

# Install its driver
arduino-cli core install arduino:avr

# Compile the sketch
arduino-cli compile -b arduino:avr:uno ./blink.ino

# Install driver so su sees the driver.
sudo arduino-cli core install arduino:avr

# SU and upload.
sudo arduino-cli upload -p /dev/ttyACM0 --fqbn arduino:avr:uno ./blink.ino
