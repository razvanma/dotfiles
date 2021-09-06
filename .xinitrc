#!/bin/sh

userresources=$HOME/.Xresources
usermodmap=$HOME/.Xmodmap
sysresources=/etc/X11/xinit/.Xresources
sysmodmap=/etc/X11/xinit/.Xmodmap

# merge in defaults and keymaps

if [ -f $sysresources ]; then
    xrdb -merge $sysresources
fi

if [ -f $sysmodmap ]; then
    xmodmap $sysmodmap
fi

if [ -f "$userresources" ]; then
    xrdb -merge "$userresources"
fi

if [ -f "$usermodmap" ]; then
    xmodmap "$usermodmap"
fi

# start some nice programs

if [ -d /etc/X11/xinit/xinitrc.d ] ; then
 for f in /etc/X11/xinit/xinitrc.d/?*.sh ; do
  [ -x "$f" ] && . "$f"
 done
 unset f
fi

# Lower the brightness,resolution band blue tones
xrandr --output eDP-1 --mode 1920x1080
xrandr --output eDP-1 --gamma 1.0:0.8:0.7 --brightness 0.39

# Get the touchpad settings going
syncclient PalmDetect=1
synclient TapButton1=1 # one-button tap
synclient TapButton2=3 # 2-button tap => right click

# Start with couple apps running
xterm &
google-chrome-stable &

# Start the window manager
exec $HOME/.local/bin/xmonad
