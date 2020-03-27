#!/usr/bin/env bash

set -e

nohup ansible-playbook -i inventory ./project0.yaml --extra-vars "@vars/project0.yaml" &> $HOME/nohup-project0.out &
echo "provisionning project0 in progress... check $HOME/nohup-project0.out for progress"