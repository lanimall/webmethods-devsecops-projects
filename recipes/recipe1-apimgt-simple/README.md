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

Now, we can provision the various products and configs by simply running.
NOTE: We load extra variables to define general values (ie. repos to use, etc...)

```bash
ansible-playbook -i inventory sagenv-stack-recipe1-apimgt-simple.yaml --extra-vars "@vars/sagenv-stack-recipe1-apimgt-simple.yaml"
```

Or using nohup (more reliable if you lose your connection etc...)

```bash
nohup ansible-playbook -i inventory sagenv-stack-recipe1-apimgt-simple.yaml --extra-vars "@vars/sagenv-stack-recipe1-apimgt-simple.yaml" &> ~/nohup-sagenv-stack-recipe1-apimgt-simple.out &
```

Check progress:

```bash
tail -f ~/nohup-sagenv-stack-recipe1-apimgt-simple.out
```

```bash
ansible-playbook -i inventory sagenv-stack-recipe1-provision-concurrent.yaml --extra-vars '{"extravars_filepath":"vars/recipe1-apimgt-simple.yaml"}'
```

## Accessing the UIs

The UI URLs will depend on the cloud provisoning prefixes and domain name you chose...
In my case:

```bash
export resources_name_prefix=sagdemoproj1
export resources_external_dns_apex=devsecops.clouddemos.saggov.com
```

Api gateway:

```bash
open https://$resources_name_prefix-apigateway-ui.$resources_external_dns_apex
```

Api gateway runtime:

```bash
open https://$resources_name_prefix-apigateway-runtime.$resources_external_dns_apex
```

Api portal:

```bash
open https://$resources_name_prefix-apiportal.$resources_external_dns_apex
```

NOTE: These urls are not added to any public DNS at this time... so you'll need to make sure you add them in your local machine's host file to be able to access them.

```bash
export AWS_MAIN_ALB=0.0.0.0
echo $AWS_MAIN_ALB $resources_name_prefix-apigateway-ui.$resources_external_dns_apex $resources_name_prefix-apigateway-runtime.$resources_external_dns_apex $resources_name_prefix-apiportal.$resources_external_dns_apex
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