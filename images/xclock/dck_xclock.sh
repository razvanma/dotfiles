# First: docker build -t xclock

xhost +local:127.0.0.1
docker run -it --rm \
           -e DISPLAY=unix$DISPLAY \
           --net=host \
           xclock 
