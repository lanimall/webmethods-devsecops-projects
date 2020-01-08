#!/usr/bin/env bash

set -e

#### ansible
sudo yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
sudo subscription-manager repos --enable "rhel-*-optional-rpms" --enable "rhel-*-extras-rpms"  --enable "rhel-ha-for-rhel-*-server-rpms"
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

#### AWS CLI
pip3 install awscli --force-reinstall --upgrade