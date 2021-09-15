# First: docker build -t xclock

docker run -it --rm \
           -e DISPLAY=unix$DISPLAY \
           --net=host \
           xclock 
