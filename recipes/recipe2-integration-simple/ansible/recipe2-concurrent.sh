#!/usr/bin/env bash

set -e

nohup ansible-playbook -i inventory ./playbooks/recipe2/terracotta.yaml --extra-vars "@vars/recipe2.yaml" &> $HOME/nohup-recipe2-terracotta.out &
echo "terracotta installation/configuration in progress... check $HOME/nohup-recipe2-terracotta.out for details"

nohup ansible-playbook -i inventory ./playbooks/recipe2/universalmessaging.yaml --extra-vars "@vars/recipe2.yaml" &> $HOME/nohup-recipe2-universalmessaging.out &
echo "universalmessaging installation/configuration in progress... check $HOME/nohup-recipe2-universalmessaging.out for details"

nohup ansible-playbook -i inventory ./playbooks/recipe2/integration.yaml --extra-vars "@vars/recipe2.yaml" &> $HOME/nohup-recipe2-integration.out &
echo "integration installation/configuration in progress... check $HOME/nohup-recipe2-integration.out for details"

nohup ansible-playbook -i inventory ./playbooks/recipe2/apigateway.yaml --extra-vars "@vars/recipe2.yaml" &> $HOME/nohup-recipe2-apigateway.out &
echo "apigateway installation/configuration in progress... check $HOME/nohup-recipe2-apigateway.out for details"

echo "All installation/configuration in progress..."