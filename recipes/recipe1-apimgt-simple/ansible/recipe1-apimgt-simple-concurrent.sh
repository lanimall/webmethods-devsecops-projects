#!/usr/bin/env bash

set -e

nohup ansible-playbook -i inventory ./playbooks/sagenv-stack-recipe1/apigateway.yaml --extra-vars "@vars/sagenv-stack-recipe1-apimgt-simple.yaml" &> $HOME/nohup-sagenv-stack-recipe1-apimgt-simple-apigateway.out &
echo "apigateway In progress... check $HOME/nohup-sagenv-stack-recipe1-apimgt-simple-apigateway.out for progress"

nohup ansible-playbook -i inventory ./playbooks/sagenv-stack-recipe1/apiportal.yaml --extra-vars "@vars/sagenv-stack-recipe1-apimgt-simple.yaml" &> $HOME/nohup-sagenv-stack-recipe1-apimgt-simple-apiportal.out &
echo "apiportal In progress... check $HOME/nohup-sagenv-stack-recipe1-apimgt-simple-apiportal.out for progress"

nohup ansible-playbook -i inventory ./playbooks/sagenv-stack-recipe1/integration.yaml --extra-vars "@vars/sagenv-stack-recipe1-apimgt-simple.yaml" &> $HOME/nohup-sagenv-stack-recipe1-apimgt-simple-integration.out &
echo "integration In progress... check $HOME/nohup-sagenv-stack-recipe1-apimgt-simple-integration.out for progress"

echo "All In progress..."