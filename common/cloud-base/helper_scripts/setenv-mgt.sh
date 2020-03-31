#!/usr/bin/env bash

##some vars for the CLI interactions
export MGT_SSH_HOST="${management1_ip}"
export MGT_SSH_USER="${management1_user}"

export DNS_APP_LOADBALANCER="${main_public_alb_dns_name}"
export DNS_EXTERNAL_COMMANDCENTRAL="${commandcentral_external_dns_name}"