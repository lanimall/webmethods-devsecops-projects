# webmethods-devsecops-projects - Common Initial Setup

## Prep tasks 1 - Generate the cloud environment skeleton

The first will be to generate all the required pieces in order to create a good cloud environment for this demo.
Using terraform scripting, we'll be creating things like:

- virtual private cloud (VPC)
- subnets
- load balancers
- security keys
- s3 bucket
- etc...

For further instructions, go to [CLOUD-BASE](./cloud-base/README.md)

## Prep tasks 2 - Setup connectivity to the servers

In "pre-tasks 1" above, you should have setup muliple certs for accessing the bastion and the internal servers.
To connect to the servers, we will need the certs, which should still be in $SAGDEVOPSDEMO_CONFIGS_PATH as explained in [CLOUD-BASE](./cloud-base/README.md).

From there, I created a script that automatically copies and sets up all the certs on the bastion and management server.

Simply run the script:

```bash
./common/setup-access-bastion.sh
```

### Test connectivity to the bastion and management server

#### Bastion

At the root of this project, run the following script to SSH to the bastion:

```bash
./ssh-to-bastion.sh
```

If able to connect, all good on this.
If not, verify that the parameters in $BASEDIR/common/cloud-base/tfexpanded/setenv-base.sh are correct.

#### Management Server

Once connected to the bastion, run the following to see if you can reach the management server:

```bash
./ssh-to-management.sh
```

If able to connect, all good on this.
If not, verify that the parameters in $HOME/setenv-mgt.sh are correct.

## Prep tasks 4 - Move code to management server

Back onto your local machine at the root of this project, let's move all the required code to the server:

```bash
./sync-to-remote.sh
```

All code should automatically be copied all the way to the management server (via the bastion)

## Prep tasks 5 - Copy content to S3

You should put in the newly created S3 bucket your webMethods license files and other artifacts that should be registered into Command Central.

If you don't remember the S3 bucket name, it is in the following script: "common/cloud-base/tfexpanded/setenv-s3.sh"

Running the following should print it for you:

```bash
. common/cloud-base/tfexpanded/setenv-s3.sh
echo $S3_BUCKET_NAME
```

Then, using AWS Console, simply upload the wM content to the S3 bucket in the 

## Prep tasks 6 - Bootstrap management server

### Bootstrap ansible / python / aws cli

Connect back onto the management server, and run:

```bash
export LINUX_DIST="centos"
cd ~/webmethods-provisioning/scripts/
./bootstrap-management-$LINUX_DIST.sh
```

This will install ansible and related binaries.

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

## Final validation task 8 - Navigate to command central UI

At this point, command central server should be fully functionnal with all the required artifacts registered (repos, licenses, passwords, etc...)

And the command central URL should be accessible at the following URL:

```bash
. ./common/cloud-management/tfexpanded/setenv-mgt.sh
echo https://$HOSTNAME_EXTERNAL_COMMANDCENTRAL/
```

NOTE: This hostname is NOT in a public DNS by default...so you will need to add this entry to your local HOSTS file with the main load-balancer IP address(es).

```bash
. ./common/cloud-management/tfexpanded/setenv-mgt.sh && \
export DNS_APP_LOADBALANCER_IP_ADDRESS=`dig +short $DNS_APP_LOADBALANCER | head -n 1` && \
echo "" && \
echo "Content to add to your Host file:" && \
echo "$DNS_APP_LOADBALANCER_IP_ADDRESS $DNS_EXTERNAL_COMMANDCENTRAL"
```
