# Use python3.7
# See https://docs.docker.com/samples/library/python/ for latest 
FROM python:3.7

ENV PATH="/root/miniconda3/bin:${PATH}"
ARG PATH="/root/miniconda3/bin:${PATH}"

# Working directory is / by default. We explictly state it here for posterity
WORKDIR /

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       apt-utils \
       build-essential \
       curl \
       xvfb \
       ffmpeg \
       xorg-dev \
       libsdl2-dev \
       swig \
       vim \
       cmake 

# Set it as the working directory
WORKDIR /home/

# Download and install miniconda
RUN curl https://repo.anaconda.com/miniconda/Miniconda3-py37_4.10.3-Linux-x86_64.sh --output Miniconda3-py37_4.10.3-Linux-x86_64.sh
RUN bash Miniconda3-py37_4.10.3-Linux-x86_64.sh -b

# Upgrade pip3
RUN pip3 install --upgrade pip

# Move the requirements file into the image
COPY requirements.txt /tmp/

# Install the python requirements on the image
RUN pip3 install --trusted-host pypi.python.org -r /tmp/requirements.txt

# conda for some reason needs an X server, so....
RUN Xvfb :1 -screen 0 1024x768x24 -ac +extension GLX +render -noreset &> xvfb.log &
RUN export DISPLAY=:1

# Note cuda tools will also be installed here.
RUN /root/miniconda3/bin/conda install -y pytorch torchvision torchaudio cudatoolkit=10.2 -c pytorch

# Copy over the start-up script and test file
ADD scripts/startup_script.sh /usr/local/bin/startup_script.sh

# Give permissions to execute
RUN chmod 777 /usr/local/bin/startup_script.sh

# Create a directory in which we can do our work
RUN mkdir /home/src/
WORKDIR /home/src/

# Set the display when we run the container. This allows us to record without the user needing to type anything explicitly
# This code snippet was taken from https://github.com/duckietown/gym-duckietown/issues/123
ENTRYPOINT ["/usr/local/bin/startup_script.sh"]
