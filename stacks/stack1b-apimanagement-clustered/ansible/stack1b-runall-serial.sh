#!/usr/bin/env bash

set -e

nohup ansible-playbook -i inventory ./project2-runall-serial.yaml --extra-vars "@vars/project2.yaml" &> $HOME/nohup-project2.out &
echo "provisionning project2 in progress... check $HOME/nohup-project2.out for progress"