FROM python:3.10-slim

WORKDIR /python-docker

COPY requirements.txt requirements.txt
RUN apt-get update && apt-get install git -y

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       apt-utils \
       build-essential \
       curl

RUN pip3 install -r requirements.txt
RUN pip3 install "git+https://github.com/openai/whisper.git" 
RUN apt-get install -y ffmpeg

#RUN pip3 install torch==1.7.1+cu110 -f https://download.pytorch.org/whl/torch_stable.html
#RUN pip3 install torchvision==0.8.2+cu110 -f https://download.pytorch.org/whl/torch_stable.html

RUN curl https://repo.anaconda.com/miniconda/Miniconda3-py37_4.10.3-Linux-x86_64.sh --output Miniconda3-py37_4.10.3-Linux-x86_64.sh
RUN bash Miniconda3-py37_4.10.3-Linux-x86_64.sh -b
#RUN /root/miniconda3/bin/conda install -y pytorch torchvision torchaudio cudatoolkit=11.1 -c pytorch -c conda-forge
RUN /root/miniconda3/bin/conda install -y pytorch torchvision torchaudio pytorch-cuda=11.6 -c pytorch -c nvidia

COPY . .

EXPOSE 5000

CMD [ "python3", "-m" , "flask", "run", "--host=0.0.0.0"]

