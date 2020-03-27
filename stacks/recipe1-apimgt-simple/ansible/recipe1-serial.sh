#!/usr/bin/env bash

set -e

nohup ansible-playbook -i inventory ./recipe1-apimgt-simple-serial.yaml --extra-vars "@vars/recipe1-apimgt-simple.yaml" &> $HOME/nohup-sagenv-stack-recipe1-apimgt-simple-serial.out &
echo "recipe1-apimgt-simple-serial in progress... check $HOME/nohup-sagenv-stack-recipe1-apimgt-simple-serial.out for progress"