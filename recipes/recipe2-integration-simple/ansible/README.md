# owcp-devops-automation

Project that leverages terraform, ansible, and softwareAG Command Central for creating a complete SoftwareAG infrastructure.

## Prepping steps

Connect to the management server:

```bash
. ./common/cloud-base/tfexpanded/setenv-base.sh
ssh -A $BASTION_SSH_USER@$BASTION_SSH_HOST
. $HOME/setenv-mgt.sh
ssh -A $MGT_SSH_USER@$MGT_SSH_HOST
```

Go into the ansible project directory:

```bash
cd ~/webmethods-provisioning/webmethods-devops-ansible/
```

Then, let's sysprep everything (preparing the new servers we just created)

```bash
ansible-playbook -i inventory sagenv-sysprep-all.yaml
```

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