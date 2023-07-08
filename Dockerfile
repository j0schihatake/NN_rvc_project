ARG TAG=latest
FROM continuumio/miniconda3:$TAG

RUN apt-get update \
    && DEBIAN_FRONTEND="noninteractive" apt-get install -y --no-install-recommends \
        git \
        locales \
        sudo \
        build-essential \
        dpkg-dev \
        wget \
        openssh-server \
        ca-certificates \
        netbase\
        tzdata \
        nano \
        software-properties-common \
        python3-venv \
        python3-tk \
        pip \
        bash \
        git \
        ncdu \
        net-tools \
        openssh-server \
        libglib2.0-0 \
        libsm6 \
        libgl1 \
        libxrender1 \
        libxext6 \
        ffmpeg \
        wget \
        curl \
        psmisc \
        rsync \
        vim \
        unzip \
        htop \
        pkg-config \
        libcairo2-dev \
        libgoogle-perftools4 libtcmalloc-minimal4  \
    && rm -rf /var/lib/apt/lists/*

# Setting up locales
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8

# RUN service ssh start

# Create user:
RUN groupadd --gid 1020 acr-group
RUN useradd -rm -d /home/acr-user -s /bin/bash -G users,sudo,acr-group -u 1000 acr-user

# Update user password:
RUN echo 'acr-user:admin' | chpasswd

RUN mkdir /home/acr-user/acr

RUN cd /home/acr-user/acr

# Clone the repository
RUN git clone https://github.com/RVC-Project/Retrieval-based-Voice-Conversion-WebUI.git /home/acr-user/acr/

RUN python3 -m pip install torch torchvision torchaudio

RUN chmod 777 /home/acr-user/acr

RUN cd /home/acr-user/acr

# Install the dependencies
RUN python3 -m pip install -r /home/acr-user/acr/requirements.txt

ADD ./models/hubert_base.pt /home/acr-user/acr/

# Preparing for login
ENV HOME /home/acr-user/acr
WORKDIR ${HOME}

CMD python app.py

# Перед тем как запускать нужно подложить модели в необходимое место:
# Качаем release и копируем необходимые файлы:
# pretrained
# pretrained_v2
# uvr5_weights
# hubert_base.pt

# Docker:
# docker build -t acr .
# docker container attach acr
# docker run -dit --name acr -p 8000:8000 -v D:/Develop/NeuronNetwork/llama_cpp/llama_cpp_java/models/pretrained:/home/acr-user/acr/pretrained -v D:/Develop/NeuronNetwork/llama_cpp/llama_cpp_java/models/pretrained_v2:/home/acr-user/acr/pretrained_v2 -v D:/Develop/NeuronNetwork/llama_cpp/llama_cpp_java/models/uvr5_weights:/home/acr-user/acr/uvr5_weights --gpus all --restart unless-stopped acr:latest
