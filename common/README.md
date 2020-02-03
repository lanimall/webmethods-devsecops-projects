# webmethods-devsecops-projects - Initial Setup Steps

Project that leverages terraform, ansible, and softwareAG Command Central for creating a complete SoftwareAG infrastructure

## Prep tasks

First, 1 time setup:
You're going to copy the internal node private key to the bastion and management node so you can copy things to them.

Copy to bastion (where PATH_TO_PRIVATE_KEY is a variable that has the right local path to the private key)

```bash
. ./common/cloud-base/tfexpanded/setenv-base.sh
scp $PATH_TO_PRIVATE_KEY $BASTION_SSH_USER@$BASTION_SSH_HOST:~/.ssh/id_rsa
ssh -A $BASTION_SSH_USER@$BASTION_SSH_HOST "chmod 600 ~/.ssh/id_rsa"
ssh -A $BASTION_SSH_USER@$BASTION_SSH_HOST "ls -al ~/.ssh/"
```

Then, connect to the bastion:

```bash
ssh -A $BASTION_SSH_USER@$BASTION_SSH_HOST
```

And then, let's copy the key to the management server the same way (where $MGT_SSH_USER and $MGT_SSH_HOST have the right values...)

```bash
export MGT_SSH_USER=centos
export MGT_SSH_HOST=<some ip>
scp ~/.ssh/id_rsa $MGT_SSH_USER@$MGT_SSH_HOST:~/.ssh/id_rsa
ssh -A $MGT_SSH_USER@$MGT_SSH_HOST "chmod 600 ~/.ssh/id_rsa"
ssh -A $MGT_SSH_USER@$MGT_SSH_HOST "ls -al ~/.ssh/"
```

Finally, try to connect to the management server:

```bash
ssh -A $MGT_SSH_USER@$MGT_SSH_HOST
```

All set for the the one-time setup!

### Move code to bastion

Move all the required code to the server

```bash
../sync-to-bastion.sh
```

Connect to the bastion

```bash
. ./common/cloud-base/tfexpanded/setenv-base.sh
ssh -A $BASTION_SSH_USER@$BASTION_SSH_HOST
```

On the bastion, copy all the artifacts to the management server:

```bash
cd webmethods-provisioning/
./sync-to-management.sh
```

Connect to the management server:

```bash
. setenv-mgt.sh
ssh $MGT_SSH_USER@$MGT_SSH_HOST
```

### Copy content to S3

You should put in S3 your license files and other artifacts that should be registered into Command Central.

### Bootstrap management server

!!These are one-time steps!!

1) Bootstrap ansible / python / aws cli

```bash
cd ~/webmethods-provisioning/scripts/
./bootstrap-management-(rhel|centos).sh
```

3) Pull content from S3

NOTE TODO: these 2 scripts should have the right BUCKET_NAME / BUCKET_PREFIX based on terraform

```bash
cd ~/scripts/
./bootstrap-devops-content.sh
./bootstrap-sag-content.sh
```

### Prepping the servers and Provisioning Command Central with Ansible

First, let's move into the ansible project:

```bash
cd ~/webmethods-provisioning/webmethods-devops-ansible/
```

Then, let's sysprep everything (this prepares all the servers for the software...ie. user, disk mounts, folder creations, permissions, firewall rules, sys configs, limits, etc...)

```bash
ansible-playbook -i inventory sagenv-sysprep-all.yaml
```

Note: This playbook should be run everytime a new server is recreated...or if some settings must be changed. 

Then, let's create the various secrets needed by command central provisoning:

```bash
ansible-playbook -i inventory sagenv-tools-cce-create-secrets.yaml
```

Then, install / configure Command Central:

```bash
ansible-playbook -i inventory sagenv-stack-cce.yaml
```

At this point, command central server should be fully functionnal with all the required artifacts registered (repos, licenses, passwords, etc...)