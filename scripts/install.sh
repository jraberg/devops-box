#!/bin/bash
set -x

TERRAFORM_VERSION="0.11.13"
PACKER_VERSION="1.3.5"

# create new ssh key
[[ ! -f /home/ubuntu/.ssh/devops-key ]] \
&& mkdir -p /home/ubuntu/.ssh \
&& chown 700 /home/ubuntu/.ssh \
&& ssh-keygen -t rsa -b 4096 -f /home/ubuntu/.ssh/devops-key -N '' \
&& chown -R ubuntu:ubuntu /home/ubuntu/.ssh \
&& chown 600 /home/ubuntu/.ssh/*

# install packages
apt-get update \
&& apt-get -y upgrade \
&& apt-get -y install docker.io ansible unzip vim jq tree

# add docker privileges
usermod -G docker ubuntu

# install pip
pip3 install -U pip
if [[ $? == 127 ]]; then
    wget -q https://bootstrap.pypa.io/get-pip.py
    python3 get-pip.py
fi

# install awscli and ebcli
pip3 install -U awscli
pip3 install -U awsebcli

#terraform
T_VERSION=$(/usr/local/bin/terraform -v | head -1 | cut -d ' ' -f 2 | tail -c +2)
T_RETVAL=${PIPESTATUS[0]}

[[ $T_VERSION != $TERRAFORM_VERSION ]] || [[ $T_RETVAL != 0 ]] \
&& wget -q https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
&& unzip -o terraform_${TERRAFORM_VERSION}_linux_amd64.zip -d /usr/local/bin \
&& rm terraform_${TERRAFORM_VERSION}_linux_amd64.zip

# packer
P_VERSION=$(/usr/local/bin/packer -v)
P_RETVAL=$?

[[ $P_VERSION != $PACKER_VERSION ]] || [[ $P_RETVAL != 1 ]] \
&& wget -q https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_amd64.zip \
&& unzip -o packer_${PACKER_VERSION}_linux_amd64.zip -d /usr/local/bin \
&& rm packer_${PACKER_VERSION}_linux_amd64.zip

# clean up
apt-get clean
