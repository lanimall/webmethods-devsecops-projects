#!/usr/bin/env bash

set -e

RUNTARGET="$1"

## validate the values to be the expected ones
function join_by { local d=$1; shift; echo -n "$1"; shift; printf "%s" "${@/#/$d}"; }
valid_args=("all" "apigwinternaldatastore" "terracotta" "apigateway" "apiportal" "update")
if [[ ! " ${valid_args[@]} " =~ " $RUNTARGET " ]]; then
    valid_values=$(join_by ' , ' ${valid_args[@]})
    echo "warning: provisioning target \"$RUNTARGET\" is not valid. Valid values are: $valid_values"
    exit 2;
fi
echo "Provisioning target \"$RUNTARGET\" is valid... will execute the right playbooks."

if [ "$RUNTARGET" = "all" ] || [ "$RUNTARGET" = "apigwinternaldatastore" ]; then
    nohup ansible-playbook -i inventory ./project2_playbook_apigwinternaldatastore.yaml --extra-vars "@vars/project2.yaml" &> $HOME/nohup-project2_playbook_apigwinternaldatastore.out &
    echo "project2_playbook_apigwinternaldatastore In progress... check $HOME/nohup-project2_playbook_apigwinternaldatastore.out for progress"
fi

#### TODO: these 2 should be serial...
if [ "$RUNTARGET" = "all" ] || [ "$RUNTARGET" = "terracotta" ]; then
    nohup ansible-playbook -i inventory ./project2_playbook_terracotta.yaml --extra-vars "@vars/project2.yaml" &> $HOME/nohup-project2_playbook_terracotta.out &
    echo "project2_playbook_terracotta In progress... check $HOME/nohup-project2_playbook_terracotta.out for progress"
fi

if [ "$RUNTARGET" = "all" ] || [ "$RUNTARGET" = "apigateway" ]; then
    nohup ansible-playbook -i inventory ./project2_playbook_apigateway.yaml --extra-vars "@vars/project2.yaml" &> $HOME/nohup-project2_playbook_apigateway.out &
    echo "project2_playbook_apigateway In progress... check $HOME/nohup-project2_playbook_apigateway.out for progress"
fi

if [ "$RUNTARGET" = "all" ] || [ "$RUNTARGET" = "apiportal" ]; then
    nohup ansible-playbook -i inventory ./project2_playbook_apiportal.yaml --extra-vars "@vars/project2.yaml" &> $HOME/nohup-project2_playbook_apiportal.out &
    echo "project2_playbook_apiportal In progress... check $HOME/nohup-project2_playbook_apiportal.out for progress"
fi

if [ "$RUNTARGET" = "update" ]; then
    nohup ansible-playbook -i inventory project2_playbook_stack_update.yaml &> $HOME/nohup-project2_playbook_stack_update.out &
    echo "project2_playbook_stack_update In progress... check $HOME/nohup-project2_playbook_stack_update.out for progress"
fi

echo "All installation/configuration in progress..."