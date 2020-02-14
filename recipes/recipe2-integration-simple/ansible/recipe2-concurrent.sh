#!/usr/bin/env bash

set -e

RUNTARGET="$1"

if [ "$RUNTARGET" = "x" ] || [ "$RUNTARGET" = "terracotta" ]; then
    nohup ansible-playbook -i inventory ./playbooks/recipe2/terracotta.yaml --extra-vars "@vars/recipe2.yaml" &> $HOME/nohup-recipe2-terracotta.out &
    echo "terracotta installation/configuration in progress... check $HOME/nohup-recipe2-terracotta.out for details"
fi

if [ "$RUNTARGET" = "x" ] || [ "$RUNTARGET" = "universalmessaging" ]; then
    nohup ansible-playbook -i inventory ./playbooks/recipe2/universalmessaging.yaml --extra-vars "@vars/recipe2.yaml" &> $HOME/nohup-recipe2-universalmessaging.out &
    echo "universalmessaging installation/configuration in progress... check $HOME/nohup-recipe2-universalmessaging.out for details"
fi

if [ "$RUNTARGET" = "x" ] || [ "$RUNTARGET" = "integration" ]; then
    nohup ansible-playbook -i inventory ./playbooks/recipe2/integration.yaml --extra-vars "@vars/recipe2.yaml" &> $HOME/nohup-recipe2-integration.out &
    echo "integration installation/configuration in progress... check $HOME/nohup-recipe2-integration.out for details"
fi

if [ "$RUNTARGET" = "x" ] || [ "$RUNTARGET" = "apigateway" ]; then
    nohup ansible-playbook -i inventory ./playbooks/recipe2/apigateway.yaml --extra-vars "@vars/recipe2.yaml" &> $HOME/nohup-recipe2-apigateway.out &
    echo "apigateway installation/configuration in progress... check $HOME/nohup-recipe2-apigateway.out for details"
fi

echo "All installation/configuration in progress..."