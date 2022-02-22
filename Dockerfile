FROM debian:stable-slim

ENV UID=1000
ENV GID=1000
ENV USER=ubuntu

WORKDIR /tmp

LABEL maintainer="Adam Scislowicz <adam.scislowicz@gmail.com>"

RUN apt-get update \
    && apt-get install -y curl gnupg2 lsb-release software-properties-common \
    && curl -fsSL https://apt.releases.hashicorp.com/gpg | apt-key add - \
    && apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main" \
    && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 93C4A3FD7BB9C367 \
    && apt-add-repository "deb http://ppa.launchpad.net/ansible/ansible/ubuntu trusty main" \
    && apt-get update \
    && apt-get upgrade -y \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    ansible \
    debconf \
    dstat \
    git \
    htop \
    iproute2 \
    neovim \
    nftables \
    netfilter-persistent \
    openssh-server \
    openssl \
    procps \
    python3 \
    python3-pip \
    rsync \
    socat \
    strace \
    sudo \
    terraform \
    tshark \
    tzdata \
    unzip \
    wget \
    && terraform -install-autocomplete \
    && pip3 install --no-cache-dir awscli nox \
    && curl https://rclone.org/install.sh | bash \
    && curl https://github.com/mozilla/sops/releases/download/v3.6.1/sops_3.6.1_amd64.deb \
        -Lo sops_3.6.1_amd64.deb && \
        dpkg -i ./sops_3.6.1_amd64.deb \
    && groupadd -g $GID $USER \
    && useradd -l -g $USER -G sudo -u $UID -m $USER \
    && echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

USER $USER

RUN mkdir /home/$USER/cloudcontrol
