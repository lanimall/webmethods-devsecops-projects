# owcp-devops-automation

Project that leverages terraform, ansible, and softwareAG Command Central for creating a complete SoftwareAG infrastructure.

## Prerequisites

At this point, the management and command server should be fully functionnal with all the required packages available.
Refer to [Initial Setup](../../common/README.md)

Also, make sure you have moved all the code to the management server...TODO: link to that page??

Finally, connect to the management server (through bastion)

```bash
ssh <bastion ip>
ssh <mgt server ip>
```

## Prepping the servers

First, let's move into the ansible project:

```bash
cd ~/webmethods-provisioning/webmethods-devops-ansible
```

Then, let's sysprep everything (this prepares all the servers for the software...ie. user, disk mounts, folder creations, permissions, firewall rules, sys configs, limits, etc...)

```bash
ansible-playbook -i inventory sagenv-sysprep-all.yaml
```

Note: This playbook should be run everytime a new server is recreated...or if some settings must be changed.

## Provisioning the components

Now, we can provision the various products and configs by simply running.
NOTE: We load extra variables to define general values (ie. repos to use, etc...)

```bash
ansible-playbook -i inventory sagenv-stack-project-apimgt-simple.yaml --extra-vars "@vars/sagenv-stack-project-apimgt-simple.yaml"
```

Or using nohup (more reliable if you lose your connection etc...)

```bash
nohup ansible-playbook -i inventory sagenv-stack-project-apimgt-simple.yaml --extra-vars "@vars/sagenv-stack-project-apimgt-simple.yaml" &> ~/nohup-sagenv-stack-project-apimgt-simple.out &
```

Check progress:

```bash
tail -f ~/nohup-sagenv-stack-project-apimgt-simple.out
```

## Some extra helpful commands

### Running only specific tasks in playbook

Just api gateway:

```bash
ansible-playbook -i inventory sagenv-stack-project-apimgt-simple.yaml --extra-vars "@vars/sagenv-stack-project-apimgt-simple.yaml" --tags install-apigateway
```

Just api portal:

```bash
ansible-playbook -i inventory sagenv-stack-project-apimgt-simple.yaml --extra-vars "@vars/sagenv-stack-project-apimgt-simple.yaml" --tags install-apiportal
```

### Skipping specific tasks

For example, running the playbook but only for the pre and post install tasks (ie. server settings and service installs etc...)

```bash
ansible-playbook -i inventory sagenv-stack-project-apimgt-simple.yaml --extra-vars "@vars/sagenv-stack-project-apimgt-simple.yaml" --tags install-apigateway --skip-tags cce_provisioning.install
```
