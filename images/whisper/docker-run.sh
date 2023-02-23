docker run \
  --rm \
  --gpus all \
  --device /dev/nvidia0 \
  --device /dev/nvidia-uvm \
  --device /dev/nvidia-uvm-tools \
  --device /dev/nvidiactl \
  -p 5000:5000 \
  whisper-api
