#!/usr/bin/env bash

set -e

nohup ansible-playbook -i inventory ./playbooks/recipe2/terracotta.yaml --extra-vars "@vars/recipe2.yaml" &> $HOME/nohup-recipe2-terracotta.out &
echo "terracotta in progress... check $HOME/nohup-recipe2-terracotta.out for details"

nohup ansible-playbook -i inventory ./playbooks/recipe2/universalmessaging.yaml --extra-vars "@vars/recipe2.yaml" &> $HOME/nohup-recipe2-universalmessaging.out &
echo "universalmessaging in progress... check $HOME/nohup-recipe2-universalmessaging.out for details"

nohup ansible-playbook -i inventory ./playbooks/recipe2/integration.yaml --extra-vars "@vars/recipe2.yaml" &> $HOME/nohup-recipe2-integration.out &
echo "integration in progress... check $HOME/nohup-recipe2-integration.out for details"

echo "All In progress..."