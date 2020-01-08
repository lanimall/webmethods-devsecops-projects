# cloud-management
This creates the management-related cloud artifacts

## Pre-requisites: Set the environment

Once you have run the "cloud-base" terraform project, it will have created the general environment artifacts and boundaries (VPC, routes, subnets, etc...).

Based on that, we'll need to provide some info to our current (and future) terraform projects we want to execute in this newly-created environment. 

In order to automatically set the right variables needed by our environment, simply execute:

```
. ../cloud-base/tfexpanded/setenv-main.sh
```

Then, if not done already, add the ssh key to the local agent for easy remote connecting:
```
ssh-add ../cloud-base/helper_scripts/sshkey_id_rsa_bastion
```

Finally, generate the ssh keys that we'll use for command central, enter a passphrase if desired (make sure to remember it, we'll need it later), and fix the permissions on the keys

```
ssh-keygen -b 2048 -t rsa -f ./helper_scripts/sshkey_rsa_saguser
chmod 600 ./helper_scripts/sshkey_*
```

It's a good idea to store this key in a safe place for later re-use if needed.

## Create base environment

Now, you can create the environment:

```bash
terraform init && terraform apply
```