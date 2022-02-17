FROM debian:stable-slim

LABEL maintainer="Adam Scislowicz <adam.scislowicz@gmail.com>"

RUN apt-get update
RUN apt-get install -y curl gnupg2 lsb-release software-properties-common

# Install terraform repo
RUN curl -fsSL https://apt.releases.hashicorp.com/gpg | apt-key add -
RUN apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"

# Install Ansible repo
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 93C4A3FD7BB9C367
RUN apt-add-repository "deb http://ppa.launchpad.net/ansible/ansible/ubuntu trusty main"

RUN apt-get update
RUN apt-get upgrade -y

RUN DEBIAN_FRONTEND=noninteractive apt-get install -y \
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
    wget

RUN terraform -install-autocomplete
RUN pip3 install awscli
RUN curl https://rclone.org/install.sh | bash

RUN curl https://github.com/mozilla/sops/releases/download/v3.6.1/sops_3.6.1_amd64.deb \
    -Lo sops_3.6.1_amd64.deb && \
    dpkg -i ./sops_3.6.1_amd64.deb

RUN groupadd -g 1000 onethousand
RUN useradd -g onethousand -G sudo -u 1000 -m user

USER user
RUN mkdir /home/user/host