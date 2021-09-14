#!/bin/bash
Xvfb :1 -screen 0 1024x768x24 -ac +extension GLX +render -noreset &> xvfb.log &
export DISPLAY=:1
if [ $# -eq 0 ]
  then
    echo Run: python test.py and look in tmpFolder for the mp4
    /bin/bash
else
  $1
fi
