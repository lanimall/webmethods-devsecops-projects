# common-cloud
This creates the base environment into which we'll create all our sample projects

## Get the code and initial setup

Run the following commands to get the terraform code, generate the ssh keys we'll need, and fix the permissions on the keys

```
ssh-keygen -b 2048 -t rsa -f ./helper_scripts/sshkey_id_rsa_bastion -q -N ""
chmod 600 ./helper_scripts/sshkey_*
```

Then, add the ssh key to the local agent for easy remote connecting:
```
ssh-add ./helper_scripts/sshkey_id_rsa_bastion
```

## Create base environment

```bash
terraform init && terraform apply
```