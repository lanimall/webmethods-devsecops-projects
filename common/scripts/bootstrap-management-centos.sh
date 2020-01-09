#!/usr/bin/env bash

set -e

#### ansible
sudo yum install -y epel-release
sudo yum install -y ansible
ansible localhost -m ping

#### Install pip3
sudo yum install -y python34
sudo yum install -y python34-setuptools

##create venv for aws cli
mkdir -p ~/.virtualenvs/awscli
python3.4 -m venv ~/.virtualenvs/awscli

##save the env in user home
echo "export PATH=$PATH:~/.virtualenvs/awscli/bin/" >> $HOME/setenv.sh

if [ -f $HOME/setenv.sh ]; then
    . $HOME/setenv.sh
fi

#### AWS CLI
pip3 install awscli --force-reinstall --upgrade