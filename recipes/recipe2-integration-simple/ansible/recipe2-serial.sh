#!/usr/bin/env bash

set -e

nohup ansible-playbook -i inventory ./recipe2-serial.yaml --extra-vars "@vars/recipe2.yaml" &> $HOME/nohup-recipe2-serial.out &
echo "recipe2 installation/configuration in progress... check $HOME/nohup-recipe2.out for progress"