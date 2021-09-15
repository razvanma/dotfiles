docker build -t openai_torch .

docker run \
   -e DISPLAY=$DISPLAY \
   -v /tmp/.X11-unix:/tmp/.X11-unix \
   --gpus all \
   --device /dev/nvidia0 \
   --device /dev/nvidia-uvm \
   --device /dev/nvidia-uvm-tools \
   --device /dev/nvidiactl \
   -e DISPLAY=unix$DISPLAY \
   --net=host \
   -it openai_pytorch
