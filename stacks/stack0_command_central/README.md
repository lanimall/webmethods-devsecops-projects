# webmethods-devsecops-stacks - Stack0 - Command Central

First, make sure that initial setup was done.
For more on that, go to [INITIAL_SETUP](../../common/README.md)

# Provisioning Command Central with Ansible

Go into the ansible project directory:

```bash
cd ~/webmethods-provisioning/webmethods-devops-ansible/
```

Then, let's sysprep everything (this prepares all the servers for the software...ie. user, disk mounts, folder creations, permissions, firewall rules, sys configs, limits, etc...)

```bash
ansible-playbook -i inventory sagenv-sysprep-all.yaml
```

Note: This playbook should be run everytime a new server is recreated...or if some settings must be changed.

Then, let's create the various secrets needed by command central provisoning (ie. remote softwareag repository user/password)

```bash
ansible-playbook -i inventory sagenv-tools-cce-create-secrets.yaml
```

Then, install / configure Command Central:

```bash
ansible-playbook -i inventory sagenv-stack-cce.yaml
```

## Validation - Navigate to command central UI

At this point, command central server should be fully functionnal with all the required artifacts registered (repos, licenses, passwords, etc...)

And the command central URL should be accessible at the following URL:

```bash
. ./common/cloud-management/tfexpanded/setenv-mgt.sh
echo https://$HOSTNAME_EXTERNAL_COMMANDCENTRAL/
```

NOTE: This hostname is NOT in a public DNS by default...so you will need to add this entry to your local HOSTS file with the main load-balancer IP address(es).


```bash
. ./common/cloud-base/tfexpanded/setenv-mgt.sh && \
export DNS_APP_LOADBALANCER_IP_ADDRESS=`dig +short $DNS_APP_LOADBALANCER | head -n 1` && \
echo "IP FOR $DNS_APP_LOADBALANCER is $DNS_APP_LOADBALANCER_IP_ADDRESS"
```
