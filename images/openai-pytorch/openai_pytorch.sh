xhost +local:127.0.0.1
xhost +local:docker

# docker build -t openai_torch .
docker run \
   --rm \
   -v /tmp/.X11-unix:/tmp/.X11-unix \
   -v `pwd`/src/:/home/src:rw \
   --gpus all \
   --device /dev/nvidia0 \
   --device /dev/nvidia-uvm \
   --device /dev/nvidia-uvm-tools \
   --device /dev/nvidiactl \
   -e DISPLAY=unix$DISPLAY \
   --net=host \
   -it openai_pytorch
