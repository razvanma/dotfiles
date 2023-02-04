docker run \
  --rm \
  --gpus all \
  --device /dev/nvidia0 \
  --device /dev/nvidia-uvm \
  --device /dev/nvidia-uvm-tools \
  --device /dev/nvidiactl \
  -v $(pwd)/content:/tf/content \
  -it tf1:latest \
  /bin/bash

#  python -c 'import tensorflow as tf; print(tf.config.list_physical_devices("GPU"))'
#  -p 8888:8888 \
#  -it tensorflow/tensorflow:latest-gpu \

