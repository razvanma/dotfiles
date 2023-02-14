docker run \
  --gpus all \
  --device /dev/nvidia0 \
  --device /dev/nvidia-uvm \
  --device /dev/nvidia-uvm-tools \
  --device /dev/nvidiactl \
  -v $(pwd)/content:/tf/content \
  -p 8888:8888 \
  -it tf-jupyter
