# owcp-devops-automation

Project that leverages terraform, ansible, and softwareAG Command Central for creating a complete SoftwareAG infrastructure.

## Prerequisites

At this point, the management and command central server should be fully functionnal with all the required packages available.
Refer to [Initial Setup](../../common/README.md)

And the command central URL should be accessible at the following URL:

```bash
open https://commandcentral.$resources_external_dns_apex/
```

Where resources_external_dns_apex is the value defined in the base terraform project.

## Cloud Provisoning steps

Refer to [Terraform Instructions](./cloudops/README.md)

## Prepping steps

First, make sure you have moved all the new code to the management server.

Then, connect to the management server (through bastion)

```bash
ssh <bastion ip>
ssh <mgt server ip>
```

Finally, run the sysprep playbook to initialize the newly-created servers.

```bash
cd ~/webmethods-provisioning/webmethods-devops-ansible
ansible-playbook -i inventory sagenv-sysprep-all.yaml
```

Note: This playbook should be run only when a new server is recreated...or if some settings must be changed.

## Provisioning the components

Now, we can provision the various products and configs by simply running either below.

### Concurrent provisioning

```bash
ansible-playbook -i inventory recipe1-apimgt-simple-concurrent.yaml
```

with nohup (more reliable if you lose your connection etc...)

```bash
nohup ansible-playbook -i inventory recipe1-apimgt-simple-concurrent.yaml &> ~/nohup-recipe1-apimgt-simple-concurrent.out &
```

Check progress:

```bash
tail -f ~/nohup-recipe1-apimgt-simple-concurrent.out
```

### Serial provisioning

```bash
ansible-playbook -i inventory recipe1-apimgt-simple.yaml --extra-vars "@vars/recipe1-apimgt-simple.yaml"
```

with nohup (more reliable if you lose your connection etc...)

```bash
nohup ansible-playbook -i inventory recipe1-apimgt-simple.yaml --extra-vars "@vars/recipe1-apimgt-simple.yaml" &> ~/nohup-recipe1-apimgt-simple-serial.out &
```

Check progress:

```bash
tail -f ~/nohup-recipe1-apimgt-simple-serial.out
```

## Some extra helpful commands

### Running only specific tasks in playbook

##### Just api gateway

```bash
ansible-playbook -i inventory sagenv-stack-recipe1-apimgt-simple.yaml --extra-vars "@vars/sagenv-stack-recipe1-apimgt-simple.yaml" --tags install-apigateway
```

With nohup:

```bash
nohup ansible-playbook -i inventory sagenv-stack-recipe1-apimgt-simple.yaml --extra-vars "@vars/sagenv-stack-recipe1-apimgt-simple.yaml" --tags install-apigateway &> ~/nohup-sagenv-stack-recipe1-apimgt-simple-apigateway.out &
```

##### Just api portal

```bash
ansible-playbook -i inventory sagenv-stack-recipe1-apimgt-simple.yaml --extra-vars "@vars/sagenv-stack-recipe1-apimgt-simple.yaml" --tags install-apiportal
```

With nohup:

```bash
nohup ansible-playbook -i inventory sagenv-stack-recipe1-apimgt-simple.yaml --extra-vars "@vars/sagenv-stack-recipe1-apimgt-simple.yaml" --tags install-apiportal &> ~/nohup-sagenv-stack-recipe1-apimgt-simple-apiportal.out &
```

##### Just integration server

```bash
ansible-playbook -i inventory sagenv-stack-recipe1-apimgt-simple.yaml --extra-vars "@vars/sagenv-stack-recipe1-apimgt-simple.yaml" --tags install-integrationserver
```

With nohup:

```bash
nohup ansible-playbook -i inventory sagenv-stack-recipe1-apimgt-simple.yaml --extra-vars "@vars/sagenv-stack-recipe1-apimgt-simple.yaml" --tags install-integrationserver &> ~/nohup-sagenv-stack-recipe1-apimgt-simple-integrationserver.out &
```

#### Skipping specific tasks

For example, running the playbook but only for the pre and post install tasks (ie. server settings and service installs etc...)

```bash
ansible-playbook -i inventory sagenv-stack-recipe1-apimgt-simple.yaml --extra-vars "@vars/sagenv-stack-recipe1-apimgt-simple.yaml" --tags install-apigateway --skip-tags cce_provisioning.install
```