# webmethods-devsecops-projects
various infrastructure-as-code project samples that demonstrate full auto-provisioning of different webmethods environments

## Prep tasks

### Move code to bastion

If you have just run the terraform base project you should be set and run:

```
./sync-to-bastion.sh
```


### Add keys to the management servers:

```
cp ~/webmethods-provisioning/.ssh/sshkey_id_rsa_internalnode ~/.ssh/id_rsa
chmod 600 ~/.ssh/id_rsa
```

### bootstrap management server

1) Bootstrap ansible / python / aws cli

```
cd ~/scripts/
./bootstrap-management-(rhel|centos).sh
```

2) configure AWS credentials to pull SAG content from S3

```
. ~/setenv.sh
aws configure
```

3) Pull content from S3

```
cd ~/scripts/
./bootstrap-devops-content.sh
./bootstrap-sag-content.sh
```

### Prepping the servers and Provisioning Command Central with Ansible

First, let's move into the ansible project:
```
cd ~/webmethods-devops-ansible/
```

Then, let's sysprep everything (this prepares all the servers for the software...ie. user, disk mounts, folder creations, permissions, firewall rules, sys configs, limits, etc...)

```
ansible-playbook -i inventory sagenv-sysprep-all.yaml
```

Note: This playbook should be run everytime a new server is recreated...or if some settings must be changed. 

Then, let's create the various secrets needed by command central provisoning:
```
ansible-playbook -i inventory sagenv-tools-cce-create-secrets.yaml
```

Then, install / configure Command Central:
```
ansible-playbook -i inventory sagenv-stack-cce.yaml
```

At this point, command central server should be fully functionnal with all the required artifacts registered (repos, licenses, passwords, etc...)