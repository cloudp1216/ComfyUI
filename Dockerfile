FROM ubuntu:22.04

COPY pkgs/ca-certificates_20240203~22.04.1_all.deb /tmp
COPY pkgs/openssl_3.0.2-0ubuntu1.18_amd64.deb /tmp
COPY pkgs/tini /usr/bin

RUN set -x \
        && dpkg -i /tmp/*.deb \
        && echo "deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy main restricted universe multiverse" > /etc/apt/sources.list \
        && echo "deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy-updates main restricted universe multiverse" >> /etc/apt/sources.list \
        && echo "deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy-backports main restricted universe multiverse" >> /etc/apt/sources.list \
        && echo "deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy-security main restricted universe multiverse" >> /etc/apt/sources.list \
        && apt clean all && apt update \
        && export DEBIAN_FRONTEND=noninteractive \
        && apt install -y build-essential vim vim-common git curl tzdata net-tools openssh-server sudo iproute2 iputils-ping lsof htop primus-libs \
        && ln -svf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && echo "Asia/Shanghai" > /etc/timezone \
        && groupadd -g 5000 ui \
        && useradd -m -s /bin/bash -u 5000 -g ui -G sudo ui \
        && echo "ui:ui" | chpasswd

USER ui
RUN set -x \
        && cd ~ \
        && curl -O --user-agent "Mozilla/5.0 (Windows NT 10.0; Win64; x64)" https://mirrors.tuna.tsinghua.edu.cn/anaconda/miniconda/Miniconda3-py312_24.11.1-0-Linux-x86_64.sh \
        && bash Miniconda3-py312_24.11.1-0-Linux-x86_64.sh -b -p ~/miniconda3 \
        && . ~/miniconda3/etc/profile.d/conda.sh \
        && conda create -n ComfyUI -y python=3.12 \
        && conda activate ComfyUI \
        && echo ". ~/miniconda3/etc/profile.d/conda.sh" >> ~/.bashrc \
        && echo "conda activate ComfyUI" >> ~/.bashrc \
        && unlink Miniconda3-py312_24.11.1-0-Linux-x86_64.sh

RUN set -x \
        && cd ~ \
        && . ~/miniconda3/etc/profile.d/conda.sh \
        && conda activate ComfyUI \
        && export HTTP_PROXY="http://x.x.x.x:1080" \
        && export HTTPS_PROXY="http://x.x.x.x:1080" \
        && git clone https://github.com/comfyanonymous/ComfyUI.git \
        && cd ~/ComfyUI \
        && pip3 cache purge \
        && pip3 install -r requirements.txt \
        && cd ~/ComfyUI/custom_nodes \
        && git clone https://github.com/cubiq/ComfyUI_IPAdapter_plus.git \
        && mkdir -p ~/ComfyUI/user/default/workflows \
        && unset HTTP_PROXY \
        && unset HTTPS_PROXY
 
COPY pkgs/entrypoint.sh /usr/bin
WORKDIR /home/ui/ComfyUI
ENTRYPOINT ["/usr/bin/entrypoint.sh"]
CMD ["python3", "main.py", "--listen", "0.0.0.0", "--port", "8188"]


