#!/usr/bin/env bash

set -e

nohup ansible-playbook -i inventory stack0.yaml &> $HOME/nohup-stack0.out &
echo "provisionning stack0 in progress... check $HOME/nohup-stack0.out for progress"