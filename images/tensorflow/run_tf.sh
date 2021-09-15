docker run \
  --rm \
  --gpus all \
  --device /dev/nvidia0 \
  --device /dev/nvidia-uvm \
  --device /dev/nvidia-uvm-tools \
  --device /dev/nvidiactl \
  -it tensorflow/tensorflow:latest-gpu \
  python -c 'import tensorflow as tf; print(tf.config.list_physical_devices("GPU"))'

