# webmethods-devsecops-projects - Initial Setup Steps

Project that leverages terraform, ansible, and softwareAG Command Central for creating a complete SoftwareAG infrastructure

## Prep tasks 1 - Generate the cloud environment skeleton

The first will be to generate all the required pieces in order to create a good cloud environment for this demo.
Using terraform scripting, we'll be creating things like:

- virtual private cloud (VPC)
- subnets
- load balancers
- security keys
- s3 bucket
- etc...

For further instructions, go to [CLOUD-BASE-SETUP](./common/cloud-base/README.md)

## Prep tasks 2 - Generate the management pieces

Once the environment skeleton is created, we'll create the management servers, mainly:

- Command Central management server (used to orchestrate the Software AG components' installs)
- Ansible management server (used to orchestrate the pre and post command central installs tasks)

For further instructions, go to [CLOUD-MANAGEMENT-SETUP](./common/cloud-management/README.md)

## Prep tasks 3 - Setup connectivity to the servers

In "pre-tasks 1" above, you should have setup muliple certs for accessibg the bastion and the internal servers.
To connect to the servers, we will need the certs.
All the certs should be in a local path at "$WEBEMTHODS_KEY_PATH".
If you missed this, go back to [CLOUD-BASE-SETUP](./common/cloud-base/README.md) for further explanations.

From there, I created a script that sets up all the certs on the bastion and managemen server.

Simply run the script:

```bash
./common/setup-access-bastion.sh
```

### Test connectivity to the bastion and management server

#### Bastion

If not done it already, add the bastion ssh key to your local agent for easy remote connecting (make sure $WEBEMTHODS_KEY_PATH is set to the right path)

```bash
. ./common/cloud-base/tfexpanded/setenv-base.sh
ssh-add $BASTION_SSH_PRIV_KEY_PATH
```

Then, connect to the bastion:

```bash
ssh -A $BASTION_SSH_USER@$BASTION_SSH_HOST
```

If able to connect, all good on this.

#### Management Server

Once connected to the bastion, run the following to see if you can reach the management server:

```bash
. $HOME/setenv-mgt.sh
ssh -A $MGT_SSH_USER@$MGT_SSH_HOST
```

If able to connect, all good on this.

## Prep tasks 4 - Move code to management server

Back onto your local machine at the root of this project, let's move all the required code to the server:

```bash
./sync-to-remote.sh
```

All code should automatically be copied all the way to the management server (via the bastion)

## Prep tasks 5 - Copy content to S3

You should put in the newly created S3 bucket your webMethods license files and other artifacts that should be registered into Command Central.
If you don't remember the S3 bucket name, it should be in env variable and can be looked up by:

```bash
echo S3_BUCKET_NAME=$S3_BUCKET_NAME
```

## Prep tasks 6 - Bootstrap management server

### Bootstrap ansible / python / aws cli

Connect back onto the management server:

```bash
. ./common/cloud-base/tfexpanded/setenv-base.sh
ssh -A $BASTION_SSH_USER@$BASTION_SSH_HOST
. $HOME/setenv-mgt.sh
ssh -A $MGT_SSH_USER@$MGT_SSH_HOST
```

And then, on the management server, run:

```bash
export LINUX_DIST="centos"
cd ~/webmethods-provisioning/scripts/
./bootstrap-management-$LINUX_DIST.sh
```

### Pull content from S3

Still on the management server, run:

```bash
cd ~/webmethods-provisioning/scripts/
./bootstrap-devops-content.sh
./bootstrap-sag-content.sh
```

That should pull all the needed content you uploaded earlier on S3.

## Prep tasks 7 - Provisioning Command Central with Ansible

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

At this point, command central server should be fully functionnal with all the required artifacts registered (repos, licenses, passwords, etc...)

And the command central URL should be accessible at the following URL:

```bash
open https://commandcentral.$resources_external_dns_apex/
```
